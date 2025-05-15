//
//  TagPickerViewModel.swift
//  Jott
//
//  Created by Chris Shireman on 5/15/25.
//


import Foundation
import SwiftUI

@MainActor
final class TagPickerViewModel: ObservableObject {
    @Published var tags: [Tag] = []
    @Published var filteredTags: [Tag] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private let fetchTagsUseCase = FetchTagsUseCase()
    private let createTagUseCase = CreateTagUseCase()
    
    func loadTags() async {
        isLoading = true
        
        do {
            tags = try await fetchTagsUseCase.execute()
            updateFilteredTags()
            isLoading = false
        } catch {
            errorMessage = "Failed to load tags: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func createTag(name: String, colorHex: String? = nil) async -> Tag? {
        do {
            let newTag = try await createTagUseCase.execute(name: name, colorHex: colorHex)
            tags.append(newTag)
            updateFilteredTags()
            return newTag
        } catch {
            errorMessage = "Failed to create tag: \(error.localizedDescription)"
            return nil
        }
    }
    
    func updateFilteredTags() {
        if searchText.isEmpty {
            filteredTags = tags.sorted { $0.usageCount > $1.usageCount }
        } else {
            filteredTags = tags.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.usageCount > $1.usageCount }
        }
    }
    
    func getPopularTags(limit: Int = 5) -> [Tag] {
        return Array(tags.sorted { $0.usageCount > $1.usageCount }.prefix(limit))
    }
}
