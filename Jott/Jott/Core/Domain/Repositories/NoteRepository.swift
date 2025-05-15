//
//  NoteRepository.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//


import Foundation
import SwiftData

final class NoteRepository: NoteRepositoryProtocol {
    private let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    func fetchNotes() async throws -> [Note] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Note>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        return try context.fetch(descriptor)
    }
    
    func fetchNotes(matching query: String) async throws -> [Note] {
        let context = ModelContext(container)
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
        let context = ModelContext(container)
        
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
        let context = ModelContext(container)
        
        // Fetch the tag first
        let tagDescriptor = FetchDescriptor<Tag>(predicate: #Predicate { $0.id == tagId })
        guard let tag = try context.fetch(tagDescriptor).first else {
            return []
        }
        
        // Return the notes associated with this tag
        return tag.notes
    }
    
    func fetchRecentNotes(limit: Int) async throws -> [Note] {
        let context = ModelContext(container)
        
        var descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        return try context.fetch(descriptor)
    }
    
    func fetchPinnedNotes() async throws -> [Note] {
        let context = ModelContext(container)
        
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
        let context = ModelContext(container)
        
        let predicate = #Predicate<Note> {
            $0.id == id
        }
        
        let descriptor = FetchDescriptor<Note>(predicate: predicate)
        let notes = try context.fetch(descriptor)
        
        return notes.first
    }
    
    func saveNote(_ note: Note) async throws {
        let context = ModelContext(container)
        
        // Update timestamp
        note.updatedAt = Date()
        
        if note.modelContext == nil {
            context.insert(note)
        }
        
        try context.save()
    }
    
    func deleteNote(_ note: Note) async throws {
        let context = ModelContext(container)
        
        context.delete(note)
        try context.save()
    }
    
    func updateNoteML(noteId: UUID, summary: String?, keyEntities: [String]?) async throws {
        let context = ModelContext(container)
        
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
}
