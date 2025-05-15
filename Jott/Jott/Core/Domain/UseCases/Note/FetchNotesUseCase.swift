//
//  FetchNotesUseCase.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//


import Foundation

@MainActor
class FetchNotesUseCase {
    @Injected(\.noteRepository) private var noteRepository: NoteRepositoryProtocol
    
    func execute() async throws -> [Note] {
        return try await noteRepository.fetchNotes()
    }
    
    func execute(id: UUID) async throws -> Note? {
        return try await noteRepository.fetchNote(withId: id)
    }
    
    func execute(matching query: String) async throws -> [Note] {
        return try await noteRepository.fetchNotes(matching: query)
    }
    
    func execute(inCategory categoryId: UUID?) async throws -> [Note] {
        return try await noteRepository.fetchNotes(inCategory: categoryId)
    }
    
    func execute(withTag tagId: UUID) async throws -> [Note] {
        return try await noteRepository.fetchNotes(withTag: tagId)
    }
    
    func executeForRecent(limit: Int = 5) async throws -> [Note] {
        return try await noteRepository.fetchRecentNotes(limit: limit)
    }
    
    func executePinned() async throws -> [Note] {
        return try await noteRepository.fetchPinnedNotes()
    }
}
