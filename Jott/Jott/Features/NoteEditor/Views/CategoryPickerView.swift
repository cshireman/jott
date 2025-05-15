//
//  CategoryPickerView.swift
//  Jott
//
//  Created by Chris Shireman on 5/15/25.
//


import SwiftUI

struct CategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CategoryPickerViewModel()
    
    let selectedCategory: Category?
    let onSelectCategory: (Category?) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    List {
                        // No category option
                        Button {
                            onSelectCategory(nil)
                            dismiss()
                        } label: {
                            HStack {
                                Text("No Category")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedCategory == nil {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        // Root categories
                        ForEach(viewModel.getRootCategories()) { category in
                            CategoryPickerRow(
                                category: category,
                                selectedCategory: selectedCategory,
                                allCategories: viewModel.categories,
                                onSelect: { selected in
                                    onSelectCategory(selected)
                                    dismiss()
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
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
            .task {
                await viewModel.loadCategories()
            }
        }
    }
}
