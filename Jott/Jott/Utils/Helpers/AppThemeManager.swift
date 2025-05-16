//
//  AppThemeManager.swift
//  Jott
//
//  Created by Chris Shireman on 5/16/25.
//


import SwiftUI

@MainActor
class AppThemeManager: ObservableObject {
    @Injected(\.userPreferencesRepository) private var repository: UserPreferencesRepositoryProtocol
    @Published var colorScheme: ColorScheme?
    
    init() {
        // Load the color scheme from preferences
        colorScheme = repository.getColorScheme()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChange),
            name: Notification.Name("ThemeChanged"),
            object: nil
        )
    }
    
    @objc private func handleThemeChange() {
        // Reload from repository when theme changes
        colorScheme = repository.getColorScheme()
    }
    
    func updateColorScheme(_ scheme: ColorScheme?) {
        colorScheme = scheme
        repository.setColorScheme(scheme)
    }
}
