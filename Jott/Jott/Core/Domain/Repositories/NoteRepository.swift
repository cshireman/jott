//
//  NoteRepository.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//


import Foundation
import SwiftData

@MainActor
final class NoteRepository: NoteRepositoryProtocol {
    private let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    func fetchNotes() async throws -> [Note] {
        let context = container.mainContext
        let descriptor = FetchDescriptor<Note>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        return try context.fetch(descriptor)
    }
    
    func fetchNotes(matching query: String) async throws -> [Note] {
        let context = container.mainContext
        let lowercaseQuery = query.lowercased()
        
        let predicate = #Predicate<Note> {
            $0.title.localizedStandardContains(lowercaseQuery) || $0.content.localizedStandardContains(lowercaseQuery)
        }
        
        let descriptor = FetchDescriptor<Note>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
    
    func fetchNotes(inCategory categoryId: UUID?) async throws -> [Note] {
        let context = container.mainContext
        
        let descriptor: FetchDescriptor<Note>
        
        if let categoryId = categoryId {
            let predicate = #Predicate<Note> {
                $0.category?.id == categoryId
            }
            
            descriptor = FetchDescriptor<Note>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
            )
        } else {
            // Notes without a category
            let predicate = #Predicate<Note> {
                $0.category == nil
            }
            
            descriptor = FetchDescriptor<Note>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
            )
        }
        
        return try context.fetch(descriptor)
    }
    
    func fetchNotes(withTag tagId: UUID) async throws -> [Note] {
        let context = container.mainContext
        
        // Fetch the tag first
        let tagDescriptor = FetchDescriptor<Tag>(predicate: #Predicate { $0.id == tagId })
        guard let tag = try context.fetch(tagDescriptor).first else {
            return []
        }
        
        // Return the notes associated with this tag
        return tag.notes
    }
    
    func fetchRecentNotes(limit: Int) async throws -> [Note] {
        let context = container.mainContext
        
        var descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        return try context.fetch(descriptor)
    }
    
    func fetchPinnedNotes() async throws -> [Note] {
        let context = container.mainContext
        
        let predicate = #Predicate<Note> {
            $0.isPinned == true
        }
        
        let descriptor = FetchDescriptor<Note>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
    
    func fetchNote(withId id: UUID) async throws -> Note? {
        let context = container.mainContext
        
        let predicate = #Predicate<Note> {
            $0.id == id
        }
        
        let descriptor = FetchDescriptor<Note>(predicate: predicate)
        let notes = try context.fetch(descriptor)
        
        return notes.first
    }
    
    func saveNote(_ note: Note) async throws {
        let context = container.mainContext
        
        // Update timestamp
        note.updatedAt = Date()
        
        // If this is a new note that hasn't been inserted yet
        if note.modelContext == nil {
            context.insert(note)
        }
        
        try context.save()
    }
    
    func deleteNote(_ note: Note) async throws {
        let context = container.mainContext
        
        context.delete(note)
        try context.save()
    }
    
    func updateNoteML(noteId: UUID, summary: String?, keyEntities: [String]?) async throws {
        let context = container.mainContext
        
        // Find the note
        let predicate = #Predicate<Note> {
            $0.id == noteId
        }
        
        let descriptor = FetchDescriptor<Note>(predicate: predicate)
        guard let note = try context.fetch(descriptor).first else {
            throw RepositoryError.itemNotFound
        }
        
        // Update ML properties
        note.summary = summary
        note.keyEntities = keyEntities
        
        try context.save()
    }
    
    func updateNote(noteId: UUID, title: String, content: String, category: Category?, tags: [Tag]) async throws {
        let context = container.mainContext
        
        // Find the note
        let notePredicate = #Predicate<Note> { $0.id == noteId }
        let noteDescriptor = FetchDescriptor<Note>(predicate: notePredicate)
        
        guard let note = try context.fetch(noteDescriptor).first else {
            throw NSError(domain: "com.jott.error", code: 404, userInfo: [NSLocalizedDescriptionKey: "Note not found"])
        }
        
        // Update basic properties
        note.title = title
        note.content = content
        note.updatedAt = Date()
        
        // Set category by fetching it from the same context
        if let categoryId = category?.id {
            let categoryDescriptor = FetchDescriptor<Category>(predicate: #Predicate { $0.id == categoryId })
            if let fetchedCategory = try context.fetch(categoryDescriptor).first {
                note.category = fetchedCategory
            } else {
                note.category = nil
            }
        } else {
            note.category = nil
        }
        
        // Handle tags
        // First, remove current tags
        note.tags.forEach { tag in
            tag.notes.removeAll(where: { $0.id == noteId })
            tag.usageCount = max(0, tag.usageCount - 1)
        }
        note.tags.removeAll()
        
        // Save tags if their model context is nil
        for tag in tags {
            if tag.modelContext == nil {
                context.insert(tag)
            }
        }
        
        // Then add tags by fetching them from the same context
        let tagIds = tags.map { $0.id }
        if !tagIds.isEmpty {
            let tagDescriptor = FetchDescriptor<Tag>(predicate: #Predicate { tagIds.contains($0.id) })
            let fetchedTags = try context.fetch(tagDescriptor)
            
            for tag in fetchedTags {
                note.tags.append(tag)
                tag.notes.append(note)
                tag.usageCount += 1
            }
        }
        
        try context.save()
    }
}
