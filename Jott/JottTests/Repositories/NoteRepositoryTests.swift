import XCTest
import SwiftData
@testable import Jott

final class NoteRepositoryTests: XCTestCase {
    var container: ModelContainer!
    var repository: NoteRepository!
    
    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Note.self, configurations: config)
        repository = await NoteRepository(container: container)
    }
    
    override func tearDown() async throws {
        container = nil
        repository = nil
    }
    
    func testFetchNotes() async throws {
        // Given
        let note = Note(title: "Test Note", content: "Test Content")
        await container.mainContext.insert(note)
        try await container.mainContext.save()
        
        // When
        let notes = try await repository.fetchNotes()
        
        // Then
        XCTAssertEqual(notes.count, 1)
        XCTAssertEqual(notes.first?.title, "Test Note")
    }
    
    func testFetchNotesMatchingQuery() async throws {
        // Given
        let note1 = Note(title: "Apple", content: "Content")
        let note2 = Note(title: "Banana", content: "Apple content")
        await container.mainContext.insert(note1)
        await container.mainContext.insert(note2)
        try await container.mainContext.save()
        
        // When
        let notes = try await repository.fetchNotes(matching: "apple")
        
        // Then
        XCTAssertEqual(notes.count, 2)
    }
    
    func testSaveNote() async throws {
        // Given
        let note = Note(title: "Test Note", content: "Test Content")
        
        // When
        try await repository.saveNote(note)
        
        // Then
        let notes = try await repository.fetchNotes()
        XCTAssertEqual(notes.count, 1)
        XCTAssertEqual(notes.first?.title, "Test Note")
    }
    
    func testDeleteNote() async throws {
        // Given
        let note = Note(title: "Test Note", content: "Test Content")
        await container.mainContext.insert(note)
        try await container.mainContext.save()
        
        // When
        try await repository.deleteNote(note)
        
        // Then
        let notes = try await repository.fetchNotes()
        XCTAssertEqual(notes.count, 0)
    }
}
