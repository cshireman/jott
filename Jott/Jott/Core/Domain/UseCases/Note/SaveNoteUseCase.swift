//
//  SaveNoteUseCase.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//


import Foundation

class SaveNoteUseCase {
    @Injected(\.noteRepository) private var noteRepository: NoteRepositoryProtocol
    
    func execute(_ note: Note) async throws {
        // Business logic could go here:
        // - Validate note content
        // - Process any text for ML analysis before saving
        // - Auto-categorize/tag if those features are enabled
        
        try await noteRepository.saveNote(note)
    }
}