//
//  FetchCategoryUseCase.swift
//  Jott
//
//  Created by Chris Shireman on 5/16/25.
//


import Foundation

actor FetchCategoryUseCase {
    @Injected(\.categoryRepository) private var categoryRepository: CategoryRepositoryProtocol
    
    func execute(id: UUID) async throws -> Category? {
        return try await categoryRepository.fetchCategory(withId: id)
    }
}
