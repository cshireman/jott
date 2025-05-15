//
//  TextAnalysisService.swift
//  Jott
//
//  Created by Chris Shireman on 5/15/25.
//


// TextAnalysisService.swift
import Foundation
import NaturalLanguage

actor TextAnalysisService {
    init() {
        // Initialize any required resources
    }
    
    /// Extracts keywords from text content
    func extractKeywords(from text: String, maxKeywords: Int = 10) async -> [String] {
        // Placeholder implementation
        // In a real implementation, this would use NLP to extract meaningful keywords
        
        let words = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 3 }  // Simple filter for words longer than 3 chars
        
        // Return a few unique words as simple keywords
        let uniqueWords = Array(Set(words)).prefix(maxKeywords)
        return Array(uniqueWords)
    }
    
    /// Suggests a category based on text content
    func suggestCategory(from text: String, categories: [Category]) async -> Category? {
        // Placeholder implementation
        // In a real implementation, this would use NLP and matching algorithms
        
        // Just return a random category for now
        if categories.isEmpty {
            return nil
        }
        
        return categories.randomElement()
    }
    
    /// Suggests tags based on text content
    func suggestTags(from text: String, existingTags: [Tag], userTags: [Tag]) async -> [Tag] {
        // Placeholder implementation
        
        // For now, just return a few random tags from userTags that aren't in existingTags
        let existingIds = Set(existingTags.map { $0.id })
        let availableTags = userTags.filter { !existingIds.contains($0.id) }
        
        // Return up to 3 random tags
        let suggestedCount = min(3, availableTags.count)
        if suggestedCount == 0 {
            return []
        }
        
        // Shuffled array of indices
        let indices = Array(0..<availableTags.count).shuffled().prefix(suggestedCount)
        return indices.map { availableTags[$0] }
    }
    
    /// Generates a summary of text content
    func generateSummary(from text: String, maxLength: Int = 150) async -> String? {
        // Placeholder implementation
        
        // For now, just take the first sentence or two
        let sentences = text.components(separatedBy: ".").filter { !$0.isEmpty }
        if sentences.isEmpty {
            return nil
        }
        
        if sentences[0].count < maxLength && sentences.count > 1 {
            // Return first two sentences if first is short
            let summary = sentences[0] + ". " + sentences[1] + "."
            if summary.count <= maxLength {
                return summary
            }
        }
        
        // Just return first sentence truncated if needed
        let firstSentence = sentences[0] + "."
        if firstSentence.count <= maxLength {
            return firstSentence
        } else {
            let truncated = String(firstSentence.prefix(maxLength - 3)) + "..."
            return truncated
        }
    }
}
