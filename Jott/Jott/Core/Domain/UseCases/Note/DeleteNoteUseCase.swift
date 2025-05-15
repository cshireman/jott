//
//  DeleteNoteUseCase.swift
//  Jott
//
//  Created by Chris Shireman on 5/15/25.
//


import Foundation

@MainActor
class DeleteNoteUseCase {
    @Injected(\.noteRepository) private var noteRepository: NoteRepositoryProtocol
    
    func execute(_ note: Note) async throws {
        try await noteRepository.deleteNote(note)
    }
    
    func execute(noteId: UUID) async throws {
        guard let note = try await noteRepository.fetchNote(withId: noteId) else {
            throw NSError(domain: "com.jott.error", code: 404, userInfo: [NSLocalizedDescriptionKey: "Note not found"])
        }
        
        try await noteRepository.deleteNote(note)
    }
}
