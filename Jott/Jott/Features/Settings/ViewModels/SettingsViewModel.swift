// SettingsViewModel.swift
import Foundation
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
    
    // Default settings
    @Published var defaultCategoryId: UUID? = nil
    @Published var availableCategories: [Category] = []
    
    // App info
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Analytics
    @Published var totalNotes = 0
    @Published var totalCategories = 0
    @Published var totalTags = 0
    
    // Repositories and use cases
    @Injected(\.userPreferencesRepository) private var userPreferencesRepository: UserPreferencesRepositoryProtocol
    @Injected(\.noteRepository) private var noteRepository: NoteRepositoryProtocol
    @Injected(\.categoryRepository) private var categoryRepository: CategoryRepositoryProtocol
    @Injected(\.tagRepository) private var tagRepository: TagRepositoryProtocol
    
    private let fetchCategoriesUseCase = FetchCategoriesUseCase()
    private let getUserPreferencesUseCase = GetUserPreferencesUseCase()
    private let saveUserPreferencesUseCase = SaveUserPreferencesUseCase()
    private let contentAnalysisService = ContentAnalysisService()
    
    init() {
        Task {
            await loadPreferences()
            await loadCategories()
            await loadStats()
        }
    }
    
    func loadPreferences() async {
        // Get preferences from repository
        colorScheme = getUserPreferencesUseCase.getColorScheme()
        enableAutoTagging = getUserPreferencesUseCase.getBool(for: .enableAutoTagging)
        enableAutoSummarization = getUserPreferencesUseCase.getBool(for: .enableAutoSummarization)
        enableRelatedNotes = getUserPreferencesUseCase.getBool(for: .enableRelatedNotes)
        defaultCategoryId = getUserPreferencesUseCase.getUUID(for: .defaultCategoryId)
    }
    
    func saveColorScheme() {
        saveUserPreferencesUseCase.setColorScheme(colorScheme)
    }
    
    func saveAutoTagging() {
        saveUserPreferencesUseCase.set(enableAutoTagging, for: .enableAutoTagging)
    }
    
    func saveAutoSummarization() {
        saveUserPreferencesUseCase.set(enableAutoSummarization, for: .enableAutoSummarization)
    }
    
    func saveRelatedNotes() {
        saveUserPreferencesUseCase.set(enableRelatedNotes, for: .enableRelatedNotes)
    }
    
    func saveDefaultCategory() {
        saveUserPreferencesUseCase.set(defaultCategoryId, for: .defaultCategoryId)
    }
    
    func loadCategories() async {
        do {
            availableCategories = try await fetchCategoriesUseCase.execute()
        } catch {
            errorMessage = "Failed to load categories: \(error.localizedDescription)"
        }
    }
    
    func loadStats() async {
        do {
            // Get counts of notes, categories, and tags
            let notes = try await noteRepository.fetchNotes()
            let categories = try await categoryRepository.fetchCategories()
            let tags = try await tagRepository.fetchTags()
            
            await MainActor.run {
                totalNotes = notes.count
                totalCategories = categories.count
                totalTags = tags.count
            }
        } catch {
            errorMessage = "Failed to load statistics: \(error.localizedDescription)"
        }
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
