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
                    List(viewModel.categoryListItems, children: \.children) { item in
                        Button {
                            onSelectCategory(item.category)
                            dismiss()
                        } label: {
                            CategoryPickerRow(
                                item: item,
                                selectedCategory: selectedCategory,
                                allCategories: viewModel.categories
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
                await viewModel.loadCategoryListItems()
            }
        }
    }
}

#Preview {
    CategoryPickerView(selectedCategory: nil, onSelectCategory: { _ in })
}
