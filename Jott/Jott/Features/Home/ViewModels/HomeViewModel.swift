//
//  HomeViewModel.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var recentNotes: [Note] = []
    @Published var pinnedNotes: [Note] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let fetchNotesUseCase = FetchNotesUseCase()
    private let saveNoteUseCase = SaveNoteUseCase()
    
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                async let recentTask = fetchNotesUseCase.executeForRecent(limit: 10)
                async let pinnedTask = fetchNotesUseCase.executePinned()
                
                let (recent, pinned) = try await (recentTask, pinnedTask)
                
                await MainActor.run {
                    self.recentNotes = recent
                    self.pinnedNotes = pinned
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load notes: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func createNewNote() {
        Task {
            do {
                let newNote = Note(title: "New Note", content: "")
                try await saveNoteUseCase.execute(newNote)
                // After saving, reload data
                loadData()
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to create note: \(error.localizedDescription)"
                }
            }
        }
    }
}
