//
//  SearchNotesUseCase.swift
//  Jott
//
//  Created by Chris Shireman on 5/16/25.
//


// SearchNotesUseCase.swift
import Foundation

actor SearchNotesUseCase {
    @Injected(\.noteRepository) private var noteRepository: NoteRepositoryProtocol
    
    func execute(criteria: SearchCriteria) async throws -> [Note] {
        // If there are no search criteria, return an empty array
        if !criteria.hasFilters {
            return []
        }
        
        // Start with all notes
        var notes = try await noteRepository.fetchNotes()
        
        // Filter by text if provided
        if !criteria.text.isEmpty {
            notes = try await noteRepository.fetchNotes(matching: criteria.text)
        }
        
        // Filter by categories if provided
        if !criteria.categoryIds.isEmpty {
            notes = notes.filter { note in
                if let category = note.category {
                    return criteria.categoryIds.contains(category.id)
                }
                return false
            }
        }
        
        // Filter by tags if provided
        if !criteria.tagIds.isEmpty {
            notes = notes.filter { note in
                for tag in note.tags {
                    if criteria.tagIds.contains(tag.id) {
                        return true
                    }
                }
                return false
            }
        }
        
        // Filter by recent if requested
        if criteria.recentOnly {
            let calendar = Calendar.current
            let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            
            notes = notes.filter { note in
                return note.updatedAt >= oneWeekAgo
            }
        }
        
        return sortByRelevance(notes: notes, searchText: criteria.text)
    }
    
    private func sortByRelevance(notes: [Note], searchText: String) -> [Note] {
            // If no search text, just sort by date
            if searchText.isEmpty {
                return notes.sorted { $0.updatedAt > $1.updatedAt }
            }
            
            // Otherwise, sort by relevance
            return notes.sorted { note1, note2 in
                let text = searchText.lowercased()
                
                // Exact title match gets highest priority
                if note1.title.lowercased() == text && note2.title.lowercased() != text {
                    return true
                }
                if note1.title.lowercased() != text && note2.title.lowercased() == text {
                    return false
                }
                
                // Title contains gets next priority
                let title1Contains = note1.title.lowercased().contains(text)
                let title2Contains = note2.title.lowercased().contains(text)
                
                if title1Contains && !title2Contains {
                    return true
                }
                if !title1Contains && title2Contains {
                    return false
                }
                
                // Then by recency
                return note1.updatedAt > note2.updatedAt
            }
        }
}
