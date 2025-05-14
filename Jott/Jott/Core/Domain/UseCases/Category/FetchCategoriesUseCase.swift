//
//  FetchCategoriesUseCase.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//


import Foundation

class FetchCategoriesUseCase {
    @Injected(\.categoryRepository) private var categoryRepository: CategoryRepositoryProtocol
    
    func execute() async throws -> [Category] {
        return try await categoryRepository.fetchCategories()
    }
    
    func executeRootOnly() async throws -> [Category] {
        return try await categoryRepository.fetchRootCategories()
    }
    
    func execute(children ofCategoryId: UUID) async throws -> [Category] {
        return try await categoryRepository.fetchChildCategories(ofCategoryId: ofCategoryId)
    }
}