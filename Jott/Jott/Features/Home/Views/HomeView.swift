//
//  HomeView.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//


import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedNoteId: UUID?
    @State private var showNoteDetail = false
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if !viewModel.pinnedNotes.isEmpty {
                            pinnedNotesSection
                        }
                        
                        recentNotesSection
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Jott")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    viewModel.createNewNote()
                }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            viewModel.loadData()
        }
        .refreshable {
            viewModel.loadData()
        }
        .navigationDestination(for: UUID.self) { noteId in
            NoteDetailView(
                noteId: noteId,
                onDelete: {
                    // Refresh notes after deletion
                    Task {
                        viewModel.loadData()
                    }
                }
            )
        }
    }
    
    private var pinnedNotesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pinned")
                .font(.headline)
            
            ForEach(viewModel.pinnedNotes) { note in
                NavigationLink(value: note.id) {
                    NoteCardView(note: note)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var recentNotesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent")
                .font(.headline)
            
            if viewModel.recentNotes.isEmpty {
                Text("No notes yet. Create your first note!")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(viewModel.recentNotes) { note in
                    NavigationLink(value: note.id) {
                        NoteCardView(note: note)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
