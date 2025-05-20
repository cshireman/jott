//
//  CategoryPickerViewModel.swift
//  Jott
//
//  Created by Chris Shireman on 5/15/25.
//

// CategoryPickerViewModel.swift
import Foundation
import SwiftUI

struct CategoryListItem: Identifiable {
    let id: UUID
    let name: String
    let category: Category?
    
    static var empty: CategoryListItem {
        CategoryListItem(id: UUID(), name: "No Category", category: nil)
    }
    
    var children: [CategoryListItem]? {
        guard let category = category else { return nil }
        return category.childCategories.map { CategoryListItem(id: $0.id, name: $0.name, category: $0) }
    }
}

@MainActor
final class CategoryPickerViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    @Published var categoryListItems: [CategoryListItem] = []
    
    private let fetchCategoriesUseCase = FetchCategoriesUseCase()
    
    func loadCategories() async {
        isLoading = true
        
        do {
            categories = try await fetchCategoriesUseCase.execute()
            isLoading = false
        } catch {
            errorMessage = "Failed to load categories: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func loadCategoryListItems() async {
        await loadCategories()
        
        var items: [CategoryListItem] = [.empty]
        let rootCategories = getRootCategories()
        items.append(contentsOf: rootCategories.map { category in
            CategoryListItem(id: category.id, name: category.name, category: category)
        })
    
        categoryListItems = items
    }
    
    func getChildCategories(for parentId: UUID) -> [Category] {
        return categories.filter { $0.parentCategory?.id == parentId }
    }
    
    func getRootCategories() -> [Category] {
        return categories.filter { $0.parentCategory == nil }
    }
}
