//
//  SaveUserPreferencesUseCase.swift
//  Jott
//
//  Created by Chris Shireman on 5/16/25.
//


import Foundation
import SwiftUI

@MainActor
class SaveUserPreferencesUseCase {
    @Injected(\.userPreferencesRepository) private var repository: UserPreferencesRepositoryProtocol
    
    func set(_ value: String?, for key: UserPreferenceKey) {
        repository.set(value, for: key)
    }
    
    func set(_ value: Bool, for key: UserPreferenceKey) {
        repository.set(value, for: key)
    }
    
    func set(_ value: Int?, for key: UserPreferenceKey) {
        repository.set(value, for: key)
    }
    
    func set(_ value: Double?, for key: UserPreferenceKey) {
        repository.set(value, for: key)
    }
    
    func set(_ value: UUID?, for key: UserPreferenceKey) {
        repository.set(value, for: key)
    }
    
    func setColorScheme(_ colorScheme: ColorScheme?) {
        repository.setColorScheme(colorScheme)
    }
    
    func resetToDefaults() {
        repository.resetToDefaults()
    }
}
