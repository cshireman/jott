//
//  SaveNoteUseCase.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//

import Foundation
import SwiftData

actor SaveNoteUseCase {
    @Injected(\.noteRepository) private var noteRepository: NoteRepositoryProtocol
    
    func execute(_ note: Note) async throws {
        try await noteRepository.saveNote(note)
    }
    
    func update(noteId: UUID, title: String, content: String, category: Category?, tags: [Tag]) async throws {
        // This method now delegates all the implementation details to the repository
        try await noteRepository.updateNote(
            noteId: noteId,
            title: title,
            content: content,
            category: category,
            tags: tags
        )
    }
    
    func updateML(noteId: UUID, summary: String?, keyEntities: [String]?) async throws {
        try await noteRepository.updateNoteML(noteId: noteId, summary: summary, keyEntities: keyEntities)
    }
}
