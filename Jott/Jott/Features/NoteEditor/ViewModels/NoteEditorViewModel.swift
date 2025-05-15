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
        }
        
        // Setup timers
        setupTimers()
    }
    
    deinit {
        analysisTimer?.cancel()
        saveTimer?.cancel()
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
    
    private func tagsEqual(_ tags1: [Tag], _ tags2: [Tag]) -> Bool {
        guard tags1.count == tags2.count else { return false }
        let ids1 = Set(tags1.map { $0.id })
        let ids2 = Set(tags2.map { $0.id })
        return ids1 == ids2
    }
    
    private func analyzeContent() async {
        // Skip analysis for very short content
        guard content.count > 20 else { return }
        
        // Generate tag suggestions
        do {
            // Fetch all user tags using the use case
            let allTags = try await fetchTagsUseCase.execute()
            
            // Get suggested tags
            let suggested = await textAnalysisService.suggestTags(
                from: content,
                existingTags: tags,
                userTags: allTags
            )
            
            // Update UI on main thread
            await MainActor.run {
                suggestedTags = suggested
            }
            
            // If uncategorized, try to suggest a category
            if category == nil {
                let categories = try await fetchCategoriesUseCase.execute()
                if let suggestedCategory = await textAnalysisService.suggestCategory(from: content, categories: categories) {
                    // Could add auto-categorization in settings
                    // Right now just leaving as a suggestion capability
                }
            }
            
            // Update note summary if needed (for longer notes)
            if content.count > 200, let noteId = noteId {
                if let summary = await textAnalysisService.generateSummary(from: content) {
                    try await saveNoteUseCase.updateML(
                        noteId: noteId,
                        summary: summary,
                        keyEntities: await textAnalysisService.extractKeywords(from: content, maxKeywords: 5)
                    )
                }
            }
        } catch {
            print("Analysis error: \(error.localizedDescription)")
        }
    }
}
