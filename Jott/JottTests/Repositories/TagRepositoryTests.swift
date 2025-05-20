import XCTest
import SwiftData
@testable import Jott

final class TagRepositoryTests: XCTestCase {
    var container: ModelContainer!
    var repository: TagRepository!
    
    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Tag.self, configurations: config)
        repository = await TagRepository(container: container)
    }
    
    override func tearDown() async throws {
        container = nil
        repository = nil
    }
    
    func testFetchTags() async throws {
        // Given
        let tag = Tag(name: "Test Tag")
        await container.mainContext.insert(tag)
        try await container.mainContext.save()
        
        // When
        let tags = try await repository.fetchTags()
        
        // Then
        XCTAssertEqual(tags.count, 1)
        XCTAssertEqual(tags.first?.name, "Test Tag")
    }
    
    func testFetchPopularTags() async throws {
        // Given
        let tag1 = Tag(name: "Popular", usageCount: 5)
        let tag2 = Tag(name: "Less Popular", usageCount: 2)
        await container.mainContext.insert(tag1)
        await container.mainContext.insert(tag2)
        try await container.mainContext.save()
        
        // When
        let tags = try await repository.fetchPopularTags(limit: 1)
        
        // Then
        XCTAssertEqual(tags.count, 1)
        XCTAssertEqual(tags.first?.name, "Popular")
    }
    
    func testSaveTag() async throws {
        // Given
        let tag = Tag(name: "Test Tag")
        
        // When
        try await repository.saveTag(tag)
        
        // Then
        let tags = try await repository.fetchTags()
        XCTAssertEqual(tags.count, 1)
        XCTAssertEqual(tags.first?.name, "Test Tag")
    }
    
    func testDeleteTag() async throws {
        // Given
        let tag = Tag(name: "Test Tag")
        await container.mainContext.insert(tag)
        try await container.mainContext.save()
        
        // When
        try await repository.deleteTag(tag)
        
        // Then
        let tags = try await repository.fetchTags()
        XCTAssertEqual(tags.count, 0)
    }
}
