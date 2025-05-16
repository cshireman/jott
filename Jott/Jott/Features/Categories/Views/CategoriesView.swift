//
//  CategoriesView.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//

import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel = CategoriesViewModel()
    @State private var showAddCategory = false
    @State private var selectedCategory: Category?
    @State private var showDeleteAlert = false
    
    var body: some View {
        List {
            ForEach(viewModel.categories) { category in
                NavigationLink(value: category) {
                    CategoryRow(category: category)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        selectedCategory = category
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        selectedCategory = category
                        showAddCategory = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .navigationTitle("Categories")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    selectedCategory = nil
                    showAddCategory = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddCategory) {
            NavigationStack {
                CategoryEditorView(
                    category: selectedCategory,
                    onSave: { newCategory in
                        Task {
                            if selectedCategory != nil {
                                await viewModel.updateCategory(newCategory)
                            } else {
                                await viewModel.addCategory(newCategory)
                            }
                        }
                    }
                )
            }
        }
        .alert("Delete Category", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let category = selectedCategory {
                    Task {
                        await viewModel.deleteCategory(category)
                    }
                }
            }
        } message: {
            if let category = selectedCategory {
                Text("Are you sure you want to delete '\(category.name)'? This will remove the category from all associated notes.")
            }
        }
        .navigationDestination(for: Category.self) { category in
            CategoryDetailView(category: category)
        }
        .onAppear {
            viewModel.loadCategories()
        }
    }
}

struct CategoryRow: View {
    let category: Category
    
    var body: some View {
        HStack {
            if let iconName = category.iconName {
                Image(systemName: iconName)
                    .foregroundColor(categoryColor)
                    .frame(width: 30, height: 30)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                
                if category.hasChildren {
                    Text("\(category.childCategories.count) subcategories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            

        }
        .padding(.vertical, 4)
    }
    
    private var categoryColor: Color {
        if let hexColor = category.colorHex, let color = Color(hex: hexColor) {
            return color
        }
        return .blue
    }
}

struct CategoryDetailView: View {
    let category: Category
    
    var body: some View {
        List {
            Section("Notes") {
                ForEach(category.notes) { note in
                    NavigationLink(value: note) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.title)
                                .font(.headline)
                            
                            Text(note.content.prefix(100))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            if category.hasChildren {
                Section("Subcategories") {
                    ForEach(category.childCategories) { subcategory in
                        NavigationLink(value: subcategory) {
                            CategoryRow(category: subcategory)
                        }
                    }
                }
            }
        }
        .navigationTitle(category.name)
        .navigationDestination(for: Note.self) { note in
            NoteDetailView(noteId: note.id)
        }
    }
}

struct CategoryEditorView: View {
    let category: Category?
    let onSave: (Category) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var iconName = ""
    @State private var colorHex = ""
    @StateObject private var viewModel = CategoriesViewModel()
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                
                HStack {
                    TextField("Icon", text: $iconName)
                    if !iconName.isEmpty {
                        Image(systemName: iconName)
                            .foregroundColor(selectedColor)
                    }
                }
                
                ColorPicker("Color", selection: Binding(
                    get: { Color(hex: colorHex) ?? .blue },
                    set: { colorHex = $0.toHex() ?? "" }
                ))
            }
        }
        .navigationTitle(category == nil ? "New Category" : "Edit Category")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let newCategory = Category(
                        id: category?.id ?? UUID(),
                        name: name,
                        iconName: iconName.isEmpty ? nil : iconName,
                        colorHex: colorHex.isEmpty ? nil : colorHex
                    )
                    onSave(newCategory)
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
        }
        .onAppear {
            if let category = category {
                name = category.name
                iconName = category.iconName ?? ""
                colorHex = category.colorHex ?? ""
            }
            viewModel.loadCategories()
        }
    }
    
    private var selectedColor: Color {
        Color(hex: colorHex) ?? .blue
    }
}
