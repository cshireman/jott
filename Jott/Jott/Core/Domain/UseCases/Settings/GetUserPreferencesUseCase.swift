//
//  GetUserPreferencesUseCase.swift
//  Jott
//
//  Created by Chris Shireman on 5/16/25.
//


import Foundation
import SwiftUI

@MainActor
class GetUserPreferencesUseCase {
    @Injected(\.userPreferencesRepository) private var repository: UserPreferencesRepositoryProtocol
    
    func getString(for key: UserPreferenceKey) -> String? {
        return repository.getString(for: key)
    }
    
    func getBool(for key: UserPreferenceKey) -> Bool {
        return repository.getBool(for: key)
    }
    
    func getInt(for key: UserPreferenceKey) -> Int? {
        return repository.getInt(for: key)
    }
    
    func getDouble(for key: UserPreferenceKey) -> Double? {
        return repository.getDouble(for: key)
    }
    
    func getUUID(for key: UserPreferenceKey) -> UUID? {
        return repository.getUUID(for: key)
    }
    
    func getColorScheme() -> ColorScheme? {
        return repository.getColorScheme()
    }
}
