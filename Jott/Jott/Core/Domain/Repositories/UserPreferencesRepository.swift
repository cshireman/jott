//
//  UserPreferencesRepository.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//


import Foundation
import SwiftUI

final class UserPreferencesRepository: UserPreferencesRepositoryProtocol {
    private var userDefaults: UserDefaults {
        UserDefaults.standard
    }
    
    init() {
    }
    
    // MARK: - Getters
    
    func getString(for key: UserPreferenceKey) -> String? {
        return userDefaults.string(forKey: key.rawValue)
    }
    
    func getBool(for key: UserPreferenceKey) -> Bool {
        return userDefaults.bool(forKey: key.rawValue)
    }
    
    func getInt(for key: UserPreferenceKey) -> Int? {
        return userDefaults.object(forKey: key.rawValue) as? Int
    }
    
    func getDouble(for key: UserPreferenceKey) -> Double? {
        return userDefaults.object(forKey: key.rawValue) as? Double
    }
    
    func getUUID(for key: UserPreferenceKey) -> UUID? {
        guard let uuidString = userDefaults.string(forKey: key.rawValue) else {
            return nil
        }
        return UUID(uuidString: uuidString)
    }
    
    func getColorScheme() -> ColorScheme? {
        guard let rawValue = userDefaults.string(forKey: UserPreferenceKey.colorScheme.rawValue) else {
            return nil
        }
        
        switch rawValue {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }
    
    // MARK: - Setters
    
    func set(_ value: String?, for key: UserPreferenceKey) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    func set(_ value: Bool, for key: UserPreferenceKey) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    func set(_ value: Int?, for key: UserPreferenceKey) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    func set(_ value: Double?, for key: UserPreferenceKey) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    func set(_ value: UUID?, for key: UserPreferenceKey) {
        userDefaults.set(value?.uuidString, forKey: key.rawValue)
    }
    
    func setColorScheme(_ colorScheme: ColorScheme?) {
        let rawValue: String?
        
        switch colorScheme {
        case .light:
            rawValue = "light"
        case .dark:
            rawValue = "dark"
        case nil:
            rawValue = nil
        @unknown default:
            rawValue = nil
        }
        
        userDefaults.set(rawValue, forKey: UserPreferenceKey.colorScheme.rawValue)
    }
    
    // MARK: - Default Values
    
    func resetToDefaults() {
        // Default settings
        set(true, for: .enableAutoSuggestions)
        set(0.7, for: .autoTaggingConfidenceThreshold)
        set(true, for: .showSummaries)
        set(true, for: .iCloudSyncEnabled)
        set(1.0, for: .fontSizeMultiplier)
        setColorScheme(nil) // System default
    }
}
