//
//  NoteEditorViewModel.swift
//  Jott
//
//  Created by Chris Shireman on 5/15/25.
//

// NoteEditorViewModel.swift
import Foundation
import Combine
import SwiftUI

@MainActor
final class NoteEditorViewModel: ObservableObject {
    // Published properties for UI binding
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var category: Category?
    @Published var tags: [Tag] = []
    @Published var suggestedTags: [Tag] = []
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?
    @Published var isNewNote: Bool = true
    @Published var hasUnsavedChanges: Bool = false
    @Published var suggestedCategory: Category?
    
    // Private properties
    private var noteId: UUID?
    private var originalTitle: String = ""
    private var originalContent: String = ""
    private var originalCategory: Category?
    private var originalTags: [Tag] = []
    
    // Use cases instead of repositories
    private let saveNoteUseCase = SaveNoteUseCase()
    private let fetchNoteUseCase = FetchNotesUseCase()
    private let fetchTagsUseCase = FetchTagsUseCase()
    private let createTagUseCase = CreateTagUseCase()
    
    private let fetchCategoriesUseCase = FetchCategoriesUseCase()
    private let fetchCategoryUseCase = FetchCategoryUseCase()
    private let getUserPreferencesUseCase = GetUserPreferencesUseCase()
    
    // Text analysis service
    private let textAnalysisService = TextAnalysisService()
    
    // Timer for auto-save and ML processing
    private var analysisTimer: Task<Void, Never>?  // Using Task instead of Timer
    private var saveTimer: Task<Void, Never>?      // Using Task instead of Timer
    
    // MARK: - Initialization
    
    init(note: Note? = nil) {
        // If we're editing an existing note
        if let note = note {
            self.noteId = note.id
            self.title = note.title
            self.content = note.content
            self.category = note.category
            self.tags = note.tags
            self.isNewNote = false
            
            // Store original values to track changes
            self.originalTitle = note.title
            self.originalContent = note.content
            self.originalCategory = note.category
            self.originalTags = note.tags
        } else {
            // For new notes, check if there's a default category set
            let defaultCategoryId = getUserPreferencesUseCase.getUUID(for: .defaultCategoryId)
            
            if let defaultCategoryId = defaultCategoryId {
                // Load the default category - this needs to be done asynchronously
                Task {
                    do {
                        if let defaultCategory = try await fetchCategoryUseCase.execute(id: defaultCategoryId) {
                            await MainActor.run {
                                self.category = defaultCategory
                            }
                        }
                    } catch {
                        print("Failed to load default category: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        // Setup timers
        setupTimers()
        setupSettingsObservers()
    }
    
    deinit {
        analysisTimer?.cancel()
        saveTimer?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    /// Saves the current note
    func saveNote() async {
        guard hasChanges() else { return }
        
        isSaving = true
        errorMessage = nil
        
        do {
            if isNewNote {
                let newNote = Note(
                    title: title.isEmpty ? "Untitled Note" : title,
                    content: content
                )
                
                // Assign category if selected
                newNote.category = category
                
                // Assign tags
                for tag in tags {
                    newNote.tags.append(tag)
                    tag.notes.append(newNote)
                    tag.usageCount += 1
                }
                
                try await saveNoteUseCase.execute(newNote)
                noteId = newNote.id
                isNewNote = false
            } else if let noteId = noteId {
                // Use the update method for existing notes
                try await saveNoteUseCase.update(
                    noteId: noteId,
                    title: title.isEmpty ? "Untitled Note" : title,
                    content: content,
                    category: category,
                    tags: tags
                )
            }
            
            // Update original values after successful save
            originalTitle = title
            originalContent = content
            originalCategory = category
            originalTags = tags
            
            hasUnsavedChanges = false
        } catch {
            errorMessage = "Failed to save note: \(error.localizedDescription)"
        }
        
        isSaving = false
    }
    
    /// Adds a tag to the note
    func addTag(_ tag: Tag) {
        guard !tags.contains(where: { $0.id == tag.id }) else { return }
        tags.append(tag)
        hasUnsavedChanges = true
    }
    
    /// Removes a tag from the note
    func removeTag(_ tag: Tag) {
        tags.removeAll(where: { $0.id == tag.id })
        hasUnsavedChanges = true
    }
    
    /// Creates a new tag and adds it to the note
    func createAndAddTag(name: String) async {
        do {
            // Use the create tag use case
            let tag = try await createTagUseCase.execute(name: name)
            addTag(tag)
        } catch {
            errorMessage = "Failed to create tag: \(error.localizedDescription)"
        }
    }
    
    /// Sets the note's category
    func setCategory(_ newCategory: Category?) {
        category = newCategory
        hasUnsavedChanges = true
    }
    
    /// Check if the note has unsaved changes
    func hasChanges() -> Bool {
        return title != originalTitle ||
               content != originalContent ||
               category?.id != originalCategory?.id ||
               !tagsEqual(tags, originalTags)
    }
    
    // MARK: - Private Methods
    
    private func setupTimers() {
        // Analysis timer using Task
        analysisTimer = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
                if !Task.isCancelled, let self = self {
                    await self.analyzeContent()
                }
            }
        }
        
        // Auto-save timer using Task
        saveTimer = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
                if !Task.isCancelled, let self = self {
                    if self.hasChanges() {
                        await self.saveNote()
                    }
                }
            }
        }
    }
    
    private func setupSettingsObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAutoTaggingChange),
            name: Notification.Name("AutoTaggingChanged"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAutoSummarizationChange),
            name: Notification.Name("AutoSummarizationChanged"),
            object: nil
        )
    }
    
    @objc private func handleAutoTaggingChange() {
        // Re-analyze content when auto-tagging setting changes
        Task {
            await analyzeContent()
        }
    }

    @objc private func handleAutoSummarizationChange() {
        // Re-analyze content when auto-summarization setting changes
        Task {
            await analyzeContent()
        }
    }
    
    private func tagsEqual(_ tags1: [Tag], _ tags2: [Tag]) -> Bool {
        guard tags1.count == tags2.count else { return false }
        let ids1 = Set(tags1.map { $0.id })
        let ids2 = Set(tags2.map { $0.id })
        return ids1 == ids2
    }
    
    private func analyzeContent() async {
        let enableAutoTagging = getUserPreferencesUseCase.getBool(for: .enableAutoTagging)
        let enableAutoSummarization = getUserPreferencesUseCase.getBool(for: .enableAutoSummarization)
            
        // Skip analysis for very short content or if analysis is disabled
        guard content.count > 20 else {
            // Clear suggestions for very short content
            suggestedTags = []
            return
        }
        
        do {
            if enableAutoTagging {
                let allTags = try await fetchTagsUseCase.execute()
                
                // Get suggested tags using our enhanced service
                let suggested = await textAnalysisService.suggestTags(
                    from: content,
                    existingTags: tags,
                    userTags: allTags
                )
                
                // Update the suggested tags on the main thread
                suggestedTags = suggested
            }
            
            // If note is uncategorized, try to suggest a category
            if category == nil {
                let categories = try await fetchCategoriesUseCase.execute()
                if let suggestion = await textAnalysisService.suggestCategory(from: content, categories: categories) {
                    // Rather than automatically applying, we could store this as a suggestion
                    // and show a UI element to accept it
                    suggestedCategory = suggestion
                }
            }
            
            // For longer notes, generate summary and extract key entities
            if enableAutoSummarization && content.count > 200, let noteId = noteId {
                // Use the enhanced analysis capabilities
                let analysis = await textAnalysisService.analyzeContent(content)
                
                // Update the note's ML properties
                try await saveNoteUseCase.updateML(
                    noteId: noteId,
                    summary: analysis.summary,
                    keyEntities: analysis.keywords
                )
            }
        } catch {
            print("Analysis error: \(error.localizedDescription)")
        }
    }
}
