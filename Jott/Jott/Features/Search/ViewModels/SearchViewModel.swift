//
//  SearchViewModel.swift
//  Jott
//
//  Created by Chris Shireman on 5/16/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    // Search inputs
    @Published var searchText = ""
    @Published var selectedCategories: Set<UUID> = []
    @Published var selectedTags: Set<UUID> = []
    @Published var showRecentOnly = false
    
    // Search results and state
    @Published var searchResults: [Note] = []
    @Published var isSearching = false
    @Published var errorMessage: String?
    
    // Available filters
    @Published var availableCategories: [Category] = []
    @Published var availableTags: [Tag] = []
    
    // Recent searches
    @Published var recentSearches: [String] = []
    
    // Private properties
    private let searchNotesUseCase = SearchNotesUseCase()
    private let fetchCategoriesUseCase = FetchCategoriesUseCase()
    private let fetchTagsUseCase = FetchTagsUseCase()
    
    private var cancellables = Set<AnyCancellable>()
    
    // User defaults key for recent searches
    private let recentSearchesKey = "com.jott.recentSearches"
    
    init() {
        // Setup search debounce
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.performSearch()
                }
            }
            .store(in: &cancellables)
        
        // Load recent searches
        loadRecentSearches()
        
        // Load available filters
        Task {
            await loadFilters()
        }
    }
    
    func performSearch() async {
        guard !searchText.isEmpty || !selectedCategories.isEmpty || !selectedTags.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        do {
            // Create search criteria
            let criteria = SearchCriteria(
                text: searchText,
                categoryIds: Array(selectedCategories),
                tagIds: Array(selectedTags),
                recentOnly: showRecentOnly
            )
            
            // Perform search
            let results = try await searchNotesUseCase.execute(criteria: criteria)
            
            // Update results
            searchResults = results
            
            // Save to recent searches if there's text
            if !searchText.isEmpty {
                addToRecentSearches(searchText)
            }
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
        }
        
        isSearching = false
    }
    
    func clearSearch() {
        searchText = ""
        selectedCategories.removeAll()
        selectedTags.removeAll()
        showRecentOnly = false
        searchResults = []
    }
    
    func toggleCategory(_ categoryId: UUID) {
        if selectedCategories.contains(categoryId) {
            selectedCategories.remove(categoryId)
        } else {
            selectedCategories.insert(categoryId)
        }
        
        Task {
            await performSearch()
        }
    }
    
    func toggleTag(_ tagId: UUID) {
        if selectedTags.contains(tagId) {
            selectedTags.remove(tagId)
        } else {
            selectedTags.insert(tagId)
        }
        
        Task {
            await performSearch()
        }
    }
    
    func useRecentSearch(_ text: String) {
        searchText = text
        // The debounce publisher will trigger the search
    }
    
    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: recentSearchesKey)
    }
    
    private func loadFilters() async {
        do {
            availableCategories = try await fetchCategoriesUseCase.execute()
            availableTags = try await fetchTagsUseCase.execute()
        } catch {
            errorMessage = "Failed to load filters: \(error.localizedDescription)"
        }
    }
    
    private func addToRecentSearches(_ search: String) {
        // Don't add duplicates
        if !recentSearches.contains(search) {
            recentSearches.insert(search, at: 0)
            
            // Keep only the most recent 10 searches
            if recentSearches.count > 10 {
                recentSearches = Array(recentSearches.prefix(10))
            }
            
            // Save to UserDefaults
            UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
        }
    }
    
    private func loadRecentSearches() {
        if let searches = UserDefaults.standard.stringArray(forKey: recentSearchesKey) {
            recentSearches = searches
        }
    }
}
