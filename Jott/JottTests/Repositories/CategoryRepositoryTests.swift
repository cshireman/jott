import XCTest
import SwiftData
@testable import Jott

final class CategoryRepositoryTests: XCTestCase {
    var container: ModelContainer!
    var repository: CategoryRepository!
    
    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Category.self, configurations: config)
        repository = await CategoryRepository(container: container)
    }
    
    override func tearDown() async throws {
        container = nil
        repository = nil
    }
    
    func testFetchCategories() async throws {
        // Given
        let category = Category(name: "Test Category")
        await container.mainContext.insert(category)
        try await container.mainContext.save()
        
        // When
        let categories = try await repository.fetchCategories()
        
        // Then
        XCTAssertEqual(categories.count, 1)
        XCTAssertEqual(categories.first?.name, "Test Category")
    }
    
    func testFetchRootCategories() async throws {
        // Given
        let parent = Category(name: "Parent")
        let child = Category(name: "Child")
        child.parentCategory = parent
        await container.mainContext.insert(parent)
        await container.mainContext.insert(child)
        try await container.mainContext.save()
        
        // When
        let categories = try await repository.fetchRootCategories()
        
        // Then
        XCTAssertEqual(categories.count, 1)
        XCTAssertEqual(categories.first?.name, "Parent")
    }
    
    func testSaveCategory() async throws {
        // Given
        let category = Category(name: "Test Category")
        
        // When
        try await repository.saveCategory(category)
        
        // Then
        let categories = try await repository.fetchCategories()
        XCTAssertEqual(categories.count, 1)
        XCTAssertEqual(categories.first?.name, "Test Category")
    }
    
    func testDeleteCategory() async throws {
        // Given
        let category = Category(name: "Test Category")
        await container.mainContext.insert(category)
        try await container.mainContext.save()
        
        // When
        try await repository.deleteCategory(category)
        
        // Then
        let categories = try await repository.fetchCategories()
        XCTAssertEqual(categories.count, 0)
    }
}
