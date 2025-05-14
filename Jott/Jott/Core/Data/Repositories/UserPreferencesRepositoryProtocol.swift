//
//  UserPreferencesRepositoryProtocol.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//


import Foundation
import SwiftUI

// Define preference keys
enum UserPreferenceKey: String {
    case colorScheme
    case fontSizeMultiplier
    case defaultCategoryId
    case enableAutoSuggestions
    case autoTaggingConfidenceThreshold
    case showSummaries
    case lastBackupDate
    case iCloudSyncEnabled
}

protocol UserPreferencesRepositoryProtocol {
    func getString(for key: UserPreferenceKey) -> String?
    func getBool(for key: UserPreferenceKey) -> Bool
    func getInt(for key: UserPreferenceKey) -> Int?
    func getDouble(for key: UserPreferenceKey) -> Double?
    func getUUID(for key: UserPreferenceKey) -> UUID?
    func getColorScheme() -> ColorScheme?
    
    func set(_ value: String?, for key: UserPreferenceKey)
    func set(_ value: Bool, for key: UserPreferenceKey)
    func set(_ value: Int?, for key: UserPreferenceKey)
    func set(_ value: Double?, for key: UserPreferenceKey)
    func set(_ value: UUID?, for key: UserPreferenceKey)
    func setColorScheme(_ colorScheme: ColorScheme?)
    
    func resetToDefaults()
}

