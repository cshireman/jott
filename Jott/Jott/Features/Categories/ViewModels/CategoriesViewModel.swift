//
//  CategoriesViewModel.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//

import Foundation
import Combine

@MainActor
final class CategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let fetchCategoriesUseCase = FetchCategoriesUseCase()
    @Injected(\.categoryRepository) private var repository: CategoryRepositoryProtocol
    
    func loadCategories() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let rootCategories = try await fetchCategoriesUseCase.executeRootOnly()
                
                await MainActor.run {
                    self.categories = rootCategories
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load categories: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func addCategory(_ category: Category) async {
        do {
            try await repository.saveCategory(category)
            loadCategories()
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to add category: \(error.localizedDescription)"
            }
        }
    }
    
    func updateCategory(_ category: Category) async {
        do {
            try await repository.saveCategory(category)
            loadCategories()
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to update category: \(error.localizedDescription)"
            }
        }
    }
    
    func deleteCategory(_ category: Category) async {
        do {
            try await repository.deleteCategory(category)
            loadCategories()
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to delete category: \(error.localizedDescription)"
            }
        }
    }
}
