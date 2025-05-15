//
//  CategoryRepository.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//


import Foundation
import SwiftData

final class CategoryRepository: CategoryRepositoryProtocol {
    private let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    func fetchCategories() async throws -> [Category] {
        let context = ModelContext(container)
        
        let descriptor = FetchDescriptor<Category>(
            sortBy: [
                SortDescriptor(\.sortOrder),
                SortDescriptor(\.name)
            ]
        )
        
        return try context.fetch(descriptor)
    }
    
    func fetchRootCategories() async throws -> [Category] {
        let context = ModelContext(container)
        
        let predicate = #Predicate<Category> {
            $0.parentCategory == nil
        }
        
        let descriptor = FetchDescriptor<Category>(
            predicate: predicate,
            sortBy: [
                SortDescriptor(\.sortOrder),
                SortDescriptor(\.name)
            ]
        )
        
        return try context.fetch(descriptor)
    }
    
    func fetchCategory(withId id: UUID) async throws -> Category? {
        let context = ModelContext(container)
        
        let predicate = #Predicate<Category> {
            $0.id == id
        }
        
        let descriptor = FetchDescriptor<Category>(predicate: predicate)
        let categories = try context.fetch(descriptor)
        
        return categories.first
    }
    
    func fetchChildCategories(ofCategoryId parentId: UUID) async throws -> [Category] {
        let context = ModelContext(container)
        
        // First get the parent category
        let parentPredicate = #Predicate<Category> {
            $0.id == parentId
        }
        
        let parentDescriptor = FetchDescriptor<Category>(predicate: parentPredicate)
        guard let parentCategory = try context.fetch(parentDescriptor).first else {
            throw RepositoryError.itemNotFound
        }
        
        // Return children, sorted by sort order and name
        return parentCategory.childCategories.sorted { 
            if $0.sortOrder == $1.sortOrder {
                return $0.name < $1.name
            }
            return $0.sortOrder < $1.sortOrder
        }
    }
    
    func saveCategory(_ category: Category) async throws {
        let context = ModelContext(container)
        
        // Update timestamp
        category.updatedAt = Date()
        
        // If this is a new category that hasn't been inserted yet
        if category.modelContext == nil {
            context.insert(category)
        }
        
        try context.save()
    }
    
    func deleteCategory(_ category: Category) async throws {
        let context = ModelContext(container)
        
        // Note: Due to the delete rule set on relationships,
        // child categories will have their parentCategory set to nil
        // and notes will have their category set to nil
        
        context.delete(category)
        try context.save()
    }
    
    func updateCategorySortOrder(categoryId: UUID, newSortOrder: Int) async throws {
        let context = ModelContext(container)
        
        let predicate = #Predicate<Category> {
            $0.id == categoryId
        }
        
        let descriptor = FetchDescriptor<Category>(predicate: predicate)
        guard let category = try context.fetch(descriptor).first else {
            throw RepositoryError.itemNotFound
        }
        
        category.sortOrder = newSortOrder
        category.updatedAt = Date()
        
        try context.save()
    }
}
