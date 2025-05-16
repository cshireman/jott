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
    @Published var relatedNotes: [Note] = []
    
    private let fetchNoteUseCase = FetchNotesUseCase()
    private let saveNoteUseCase = SaveNoteUseCase()
    private let deleteNoteUseCase = DeleteNoteUseCase()
    private let contentAnalysisService = ContentAnalysisService()
    
    func loadNote(id: UUID) async {
        isLoading = true
        
        do {
            note = try await fetchNoteUseCase.execute(id: id)
            isLoading = false
            
            if note != nil {
                await loadRelatedNotes()
            }
        } catch {
            errorMessage = "Failed to load note: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func loadRelatedNotes() async {
        guard let note = note else { return }
        
        do {
            relatedNotes = try await contentAnalysisService.findRelatedNotes(forNoteId: note.id)
        } catch {
            print("Error loading related notes: \(error.localizedDescription)")
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
