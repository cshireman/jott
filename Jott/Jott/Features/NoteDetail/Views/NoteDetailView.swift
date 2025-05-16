//
//  NoteDetailView.swift
//  Jott
//
//  Created by Chris Shireman on 5/15/25.
//


import SwiftUI

struct NoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: NoteDetailViewModel
    @State private var showEditSheet = false
    
    let noteId: UUID
    let onDelete: (() -> Void)?
    
    init(noteId: UUID, onDelete: (() -> Void)? = nil) {
        self.noteId = noteId
        self.onDelete = onDelete
        _viewModel = StateObject(wrappedValue: NoteDetailViewModel())
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let note = viewModel.note {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Title
                        Text(note.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        // Category
                        if let category = note.category {
                            CategoryPill(category: category)
                        }
                        
                        // Tags
                        if !note.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(note.tags) { tag in
                                        TagChip(tag: tag)
                                    }
                                }
                            }
                        }
                        
                        // Summary (if available)
                        if let summary = note.summary {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Summary")
                                    .font(.headline)
                                
                                Text(summary)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.secondary.opacity(0.1))
                                    )
                            }
                            .padding(.vertical, 8)
                        }
                        
                        if let keyEntities = note.keyEntities, !keyEntities.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Key Topics")
                                    .font(.headline)
                                
                                HStack {
                                    ForEach(keyEntities, id: \.self) { entity in
                                        Text(entity)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                Capsule()
                                                    .fill(Color.blue.opacity(0.1))
                                            )
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // Content
                        FormattedTextView(text: note.content)
                            .padding(.top, 8)
                        
                        relatedNotesSection
                        
                        // Metadata
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Created: \(formatDate(note.createdAt))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("Last modified: \(formatDate(note.updatedAt))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 16)
                    }
                    .padding()
                }
            } else {
                Text("Note not found")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Note Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let note = viewModel.note {
                    Menu {
                        Button {
                            showEditSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button {
                            Task {
                                await viewModel.togglePinned()
                            }
                        } label: {
                            Label(note.isPinned ? "Unpin" : "Pin", 
                                  systemImage: note.isPinned ? "pin.slash" : "pin")
                        }
                        
                        Button(role: .destructive) {
                            viewModel.showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let note = viewModel.note {
                NavigationStack {
                    NoteEditorView(note: note)
                }
            }
        }
        .alert("Delete Note", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    if await viewModel.deleteNote() {
                        onDelete?()
                        dismiss()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this note? This action cannot be undone.")
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .overlay {
            if viewModel.isDeleting {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .task {
            await viewModel.loadNote(id: noteId)
        }
    }
    
    private var relatedNotesSection: some View {
        Group {
            if !viewModel.relatedNotes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Related Notes")
                        .font(.headline)
                    
                    ForEach(viewModel.relatedNotes) { relatedNote in
                        NavigationLink(value: relatedNote.id) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(relatedNote.title)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                    
                                    Text(relatedNote.content.prefix(60) + "...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.secondary.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 16)
            }
        }
    }

    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
