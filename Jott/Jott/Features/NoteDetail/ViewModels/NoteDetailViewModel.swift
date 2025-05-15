//
//  NoteDetailViewModel.swift
//  Jott
//
//  Created by Chris Shireman on 5/15/25.
//


import Foundation
import SwiftUI
import Combine

@MainActor
final class NoteDetailViewModel: ObservableObject {
    @Published var note: Note?
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var showDeleteConfirmation = false
    @Published var isDeleting = false
    
    private let fetchNoteUseCase = FetchNotesUseCase()
    private let saveNoteUseCase = SaveNoteUseCase()
    private let deleteNoteUseCase = DeleteNoteUseCase() // We'll need to implement this
    
    func loadNote(id: UUID) async {
        isLoading = true
        
        do {
            note = try await fetchNoteUseCase.execute(id: id)
            isLoading = false
        } catch {
            errorMessage = "Failed to load note: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func deleteNote() async -> Bool {
        guard let note = note else { return false }
        
        isDeleting = true
        
        do {
            try await deleteNoteUseCase.execute(note)
            isDeleting = false
            return true
        } catch {
            errorMessage = "Failed to delete note: \(error.localizedDescription)"
            isDeleting = false
            return false
        }
    }
    
    func togglePinned() async {
        guard let note = note else { return }
        
        do {
            note.isPinned.toggle()
            try await saveNoteUseCase.execute(note)
            self.note = note
        } catch {
            errorMessage = "Failed to update note: \(error.localizedDescription)"
        }
    }
}
