//
//  JottApp.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//

import SwiftUI
import SwiftData

@main
struct JottApp: App {
    
    private var container: ModelContainer = ModelContainerHelper.shared.container
    @StateObject private var themeManager = AppThemeManager()
    
    init() {
        setupDependencies()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
        }
        .modelContainer(container)
    }
    
    private func setupDependencies() {
        // Initialize repositories with proper dependencies
        InjectedValues[\.noteRepository] = NoteRepository(container: container)
        InjectedValues[\.categoryRepository] = CategoryRepository(container: container)
        InjectedValues[\.tagRepository] = TagRepository(container: container)
        
        // Initialize user preferences and set defaults if needed
        let userPrefsRepo = UserPreferencesRepository()
        if userPrefsRepo.getDouble(for: .autoTaggingConfidenceThreshold) == nil {
            userPrefsRepo.resetToDefaults()
        }
        
        InjectedValues[\.userPreferencesRepository] = userPrefsRepo
    }
}
