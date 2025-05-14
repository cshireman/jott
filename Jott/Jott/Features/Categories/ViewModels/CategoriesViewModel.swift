//
//  CategoriesViewModel.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//


import Foundation
import Combine

@MainActor
class CategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let fetchCategoriesUseCase = FetchCategoriesUseCase()
    
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
}
