//
//  SettingsViewModel.swift
//  Jott
//
//  Created by Chris Shireman on 5/16/25.
//


// SettingsViewModel.swift
import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    // App appearance
    @Published var colorScheme: ColorScheme? = nil
    
    // ML features
    @Published var enableAutoTagging = true
    @Published var enableAutoSummarization = true
    @Published var enableRelatedNotes = true
    
    // Data management
    @Published var iCloudSyncEnabled = true
    
    // Note defaults
    @Published var defaultCategoryId: UUID? = nil
    
    // Available categories for default selection
    @Published var availableCategories: [Category] = []
    
    // Status
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // User stats
    @Published var totalNotes = 0
    @Published var totalCategories = 0
    @Published var totalTags = 0
    
    private let fetchCategoriesUseCase = FetchCategoriesUseCase()
    private let contentAnalysisService = ContentAnalysisService()
    private let userPreferencesRepository = UserPreferencesRepository()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSettings()
        
        Task {
            await loadCategories()
            await loadStats()
        }
    }
    
    func loadSettings() {
        // Load from UserDefaults
        enableAutoTagging = UserDefaults.standard.bool(forKey: "enableAutoTagging")
        enableAutoSummarization = UserDefaults.standard.bool(forKey: "enableAutoSummarization")
        enableRelatedNotes = UserDefaults.standard.bool(forKey: "enableRelatedNotes")
        iCloudSyncEnabled = UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
        
        if let colorSchemeValue = UserDefaults.standard.string(forKey: "colorScheme") {
            colorScheme = colorSchemeValue == "dark" ? .dark : (colorSchemeValue == "light" ? .light : nil)
        }
        
        if let defaultCategoryString = UserDefaults.standard.string(forKey: "defaultCategoryId") {
            defaultCategoryId = UUID(uuidString: defaultCategoryString)
        }
    }
    
    func saveSettings() {
        UserDefaults.standard.set(enableAutoTagging, forKey: "enableAutoTagging")
        UserDefaults.standard.set(enableAutoSummarization, forKey: "enableAutoSummarization")
        UserDefaults.standard.set(enableRelatedNotes, forKey: "enableRelatedNotes")
        UserDefaults.standard.set(iCloudSyncEnabled, forKey: "iCloudSyncEnabled")
        
        // Save color scheme preference
        if let scheme = colorScheme {
            UserDefaults.standard.set(scheme == .dark ? "dark" : "light", forKey: "colorScheme")
        } else {
            UserDefaults.standard.set(nil, forKey: "colorScheme")
        }
        
        // Save default category
        UserDefaults.standard.set(defaultCategoryId?.uuidString, forKey: "defaultCategoryId")
    }
    
    private func loadCategories() async {
        do {
            availableCategories = try await fetchCategoriesUseCase.execute()
        } catch {
            errorMessage = "Failed to load categories: \(error.localizedDescription)"
        }
    }
    
    private func loadStats() async {
        // Load stats from repositories
        // This would typically query the repositories for counts
    }
    
    func runContentAnalysis(progressCallback: @MainActor (Double) -> Void) async -> Int {
        isLoading = true
        
        do {
            let count = try await contentAnalysisService.analyzeAllNotes(progressCallback: progressCallback)
            isLoading = false
            return count
        } catch {
            errorMessage = "Analysis failed: \(error.localizedDescription)"
            isLoading = false
            return 0
        }
    }
}
