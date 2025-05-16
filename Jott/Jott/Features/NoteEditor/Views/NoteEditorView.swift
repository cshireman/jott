//
//  NoteEditorView.swift
//  Jott
//
//  Created by Chris Shireman on 5/15/25.
//

import SwiftUI

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: NoteEditorViewModel
    @FocusState private var focusField: Field?
    
    // State for various sheets and dialogs
    @State private var showCategoryPicker = false
    @State private var showTagPicker = false
    @State private var newTagName = ""
    @State private var showAddTagDialog = false
    
    enum Field: Hashable {
        case title
        case content
    }
    
    init(note: Note? = nil) {
        _viewModel = StateObject(wrappedValue: NoteEditorViewModel(note: note))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            editorToolbar
            
            // Editor content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Title field
                    TextField("Title", text: $viewModel.title)
                        .font(.system(size: 22, weight: .bold))
                        .focused($focusField, equals: .title)
                        .onChange(of: viewModel.title) { _, _ in
                            viewModel.hasUnsavedChanges = true
                        }
                    
                    if viewModel.category == nil {
                        suggestedCategoryView
                    }
                    
                    // Tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.tags) { tag in
                                TagView(tag: tag) {
                                    viewModel.removeTag(tag)
                                }
                            }
                            
                            // Add tag button
                            Button(action: {
                                showTagPicker = true
                            }) {
                                Label("Add", systemImage: "plus")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue, lineWidth: 1)
                                    )
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Content field
                    TextEditor(text: $viewModel.content)
                        .frame(minHeight: 300)
                        .focused($focusField, equals: .content)
                        .onChange(of: viewModel.content) { _, _ in
                            viewModel.hasUnsavedChanges = true
                        }
                        .cornerRadius(8)
                        .padding(.vertical, 4)
                }
                .padding()
            }
            
            // Suggested tags (will be populated in step 3)
            if !viewModel.suggestedTags.isEmpty {
                suggestedTagsView
            }
        }
        .navigationTitle(viewModel.isNewNote ? "New Note" : "Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await viewModel.saveNote()
                        dismiss()
                    }
                } label: {
                    Text("Done")
                }
                .disabled(viewModel.isSaving)
            }
        }
        .overlay {
            if viewModel.isSaving {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
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
        .sheet(isPresented: $showCategoryPicker) {
            CategoryPickerView(
                selectedCategory: viewModel.category,
                onSelectCategory: { category in
                    viewModel.setCategory(category)
                }
            )
        }
        .sheet(isPresented: $showTagPicker) {
            TagPickerView(
                selectedTags: viewModel.tags,
                onSelectTag: { tag in
                    viewModel.addTag(tag)
                }
            )
        }
        .alert("Add Tag", isPresented: $showAddTagDialog) {
            TextField("Tag Name", text: $newTagName)
            
            Button("Cancel", role: .cancel) {
                newTagName = ""
            }
            
            Button("Add") {
                if !newTagName.isEmpty {
                    Task {
                        await viewModel.createAndAddTag(name: newTagName)
                        newTagName = ""
                    }
                }
            }
        } message: {
            Text("Enter a name for the new tag")
        }
        .onAppear {
            // Focus on title if new note, content if existing
            focusField = viewModel.isNewNote ? .title : .content
        }
        .onDisappear {
            if viewModel.hasChanges() {
                Task {
                    await viewModel.saveNote()
                }
            }
        }
    }
    
    private var editorToolbar: some View {
        HStack(spacing: 16) {
            // Basic formatting buttons
            Button(action: {
                // Bold text implementation
            }) {
                Image(systemName: "bold")
            }
            
            Button(action: {
                // Italic text implementation
            }) {
                Image(systemName: "italic")
            }
            
            Button(action: {
                // Checklist implementation
            }) {
                Image(systemName: "checklist")
            }
            
            Button(action: {
                // Bullet list implementation
            }) {
                Image(systemName: "list.bullet")
            }
            
            Spacer()
            
            // Category dropdown
            Button {
                showCategoryPicker = true
            } label: {
                HStack {
                    if let category = viewModel.category {
                        if let iconName = category.iconName {
                            Image(systemName: iconName)
                                .foregroundColor(getCategoryColor(category))
                        }
                        Text(category.name)
                            .font(.caption)
                    } else {
                        Text("No Category")
                            .font(.caption)
                    }
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.2))
                )
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
    }
    
    private var suggestedTagsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Suggested Tags")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.suggestedTags) { tag in
                        Button {
                            viewModel.addTag(tag)
                        } label: {
                            HStack {
                                Text(tag.name)
                                    .lineLimit(1)
                                
                                if tag.isAutoGenerated {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 10))
                                }
                            }
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                            .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 40)
            .padding(.bottom, 8)
        }
        .background(Color(UIColor.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .top
        )
    }
    
    private var suggestedCategoryView: some View {
        Group {
            if let suggestedCategory = viewModel.suggestedCategory, viewModel.category == nil {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Suggested Category")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        if let iconName = suggestedCategory.iconName {
                            Image(systemName: iconName)
                                .foregroundColor(getCategoryColor(suggestedCategory))
                        }
                        
                        Text(suggestedCategory.name)
                            .font(.caption)
                        
                        Spacer()
                        
                        Button("Apply") {
                            viewModel.setCategory(suggestedCategory)
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.1))
                    )
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
        }
    }
    
    
    private func getCategoryColor(_ category: Category) -> Color {
        if let hexColor = category.colorHex, let color = Color(hex: hexColor) {
            return color
        }
        return .blue
    }
}
