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
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                
                    Text("\(category.childCategories.count) subcategories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            
