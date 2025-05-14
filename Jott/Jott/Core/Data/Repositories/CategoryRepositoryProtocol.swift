//
//  CategoryRepositoryProtocol.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//

import Foundation

protocol CategoryRepositoryProtocol {
    func fetchCategories() async throws -> [Category]
    func fetchRootCategories() async throws -> [Category]
    func fetchCategory(withId id: UUID) async throws -> Category?
    func fetchChildCategories(ofCategoryId parentId: UUID) async throws -> [Category]
    func saveCategory(_ category: Category) async throws
    func deleteCategory(_ category: Category) async throws
    func updateCategorySortOrder(categoryId: UUID, newSortOrder: Int) async throws
}
