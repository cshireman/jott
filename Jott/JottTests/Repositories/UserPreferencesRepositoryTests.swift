import XCTest
import SwiftUI
@testable import Jott

final class UserPreferencesRepositoryTests: XCTestCase {
    var repository: UserPreferencesRepository!
    let testKey = UserPreferenceKey.enableAutoTagging
    
    override func setUp() {
        repository = UserPreferencesRepository()
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    override func tearDown() {
        repository = nil
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    func testSetAndGetString() {
        // Given
        let testString = "test value"
        
        // When
        repository.set(testString, for: testKey)
        let retrieved = repository.getString(for: testKey)
        
        // Then
        XCTAssertEqual(retrieved, testString)
    }
    
    func testSetAndGetBool() {
        // Given
        let testBool = true
        
        // When
        repository.set(testBool, for: testKey)
        let retrieved = repository.getBool(for: testKey)
        
        // Then
        XCTAssertEqual(retrieved, testBool)
    }
    
    func testSetAndGetDouble() {
        // Given
        let testDouble = 1.5
        
        // When
        repository.set(testDouble, for: testKey)
        let retrieved = repository.getDouble(for: testKey)
        
        // Then
        XCTAssertEqual(retrieved, testDouble)
    }
    
    func testSetAndGetColorScheme() {
        // Given
        let testScheme = ColorScheme.dark
        
        // When
        repository.setColorScheme(testScheme)
        let retrieved = repository.getColorScheme()
        
        // Then
        XCTAssertEqual(retrieved, testScheme)
    }
}