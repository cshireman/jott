//
//  CategoryPickerViewModel.swift
//  Jott
//
//  Created by Chris Shireman on 5/15/25.
//


// CategoryPickerViewModel.swift
import Foundation
import SwiftUI

@MainActor
final class CategoryPickerViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    
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
    
    func getChildCategories(for parentId: UUID) -> [Category] {
        return categories.filter { $0.parentCategory?.id == parentId }
    }
    
    func getRootCategories() -> [Category] {
        return categories.filter { $0.parentCategory == nil }
    }
}