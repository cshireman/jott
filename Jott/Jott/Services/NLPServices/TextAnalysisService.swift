//
//  TextAnalysisService.swift
//  Jott
//
//  Created by Chris Shireman on 3/20/24
//

import Foundation
import NaturalLanguage

actor TextAnalysisService {
    // NLP taggers for different types of analysis
    private let tokenTagger = NLTagger(tagSchemes: [.tokenType, .lemma])
    // Use proper sentence detection scheme
    private let sentenceTagger = NLTagger(tagSchemes: [.lexicalClass])
    private let entityTagger = NLTagger(tagSchemes: [.nameType])
    private let lexicalTagger = NLTagger(tagSchemes: [.lexicalClass])
    
    // Stop words to filter out common words that don't add meaning
    private let stopWords = Set([
        "the", "and", "a", "to", "of", "in", "that", "is", "for", "with", "on", "at",
        "this", "by", "from", "be", "as", "but", "or", "have", "had", "has", "was",
        "were", "are", "an", "will", "would", "should", "could", "it", "its", "it's",
        "they", "them", "their", "what", "which", "who", "whom", "whose", "when",
        "where", "why", "how", "all", "any", "both", "each", "more", "most", "other",
        "some", "such", "than", "too", "very", "just", "can", "cannot", "can't", "don't",
        "doesn't", "didn't", "won't", "wouldn't", "shouldn't", "couldn't"
    ])
    
    init() {
    }
    
    /// Extracts the most significant keywords from text content
    func extractKeywords(from text: String, maxKeywords: Int = 10) -> [String] {
        guard !text.isEmpty else { return [] }
        
        // Prepare the tagger
        lexicalTagger.string = text
        entityTagger.string = text
        
        // Initialize storage for keywords and their relevance scores
        var keywords = [String: Double]()
        
        // Track important lexical classes like nouns, verbs, and adjectives
        let importantClasses: [NLTag] = [.noun, .verb, .adjective]
        
        // Extract entities (people, places, organizations)
        let entityRange = text.startIndex..<text.endIndex
        entityTagger.enumerateTags(in: entityRange, unit: .word, scheme: .nameType) { tag, tokenRange in
            if let tag = tag, tag != .other {
                let entity = String(text[tokenRange]).lowercased()
                
                // Give entities a high score as they're usually important keywords
                keywords[entity, default: 0] += 3.0
            }
            return true
        }
        
        // Extract important words by lexical class
        lexicalTagger.enumerateTags(in: entityRange, unit: .word, scheme: .lexicalClass) { tag, tokenRange in
            if let tag = tag, importantClasses.contains(tag) {
                let word = String(text[tokenRange]).lowercased()
                
                // Filter out short words and stop words
                guard word.count > 2, !self.stopWords.contains(word) else { return true }
                
                // Score based on lexical class (nouns are more important than verbs)
                var score: Double = 1.0
                if tag == .noun { score = 2.0 }
                if tag == .adjective { score = 1.5 }
                
                // Add to keywords with appropriate score
                keywords[word, default: 0] += score
            }
            return true
        }
        
        // Sort keywords by score and return top results
        return Array(keywords.sorted { $0.value > $1.value }
            .prefix(maxKeywords)
            .map { $0.key })
    }
    
    /// Suggests a category based on content analysis
    func suggestCategory(from text: String, categories: [Category]) -> Category? {
        guard !text.isEmpty, !categories.isEmpty else { return nil }
        
        // Extract keywords to match against categories
        let keywords = extractKeywords(from: text, maxKeywords: 20)
        
        // Calculate a match score for each category
        var categoryScores = [UUID: Double]()
        
        for category in categories {
            let categoryName = category.name.lowercased()
            var score = 0.0
            
            // Direct name match is the strongest signal
            if keywords.contains(where: { categoryName.contains($0) || $0.contains(categoryName) }) {
                score += 10.0
            }
            
            // Check if any keywords match the category name
            for (index, keyword) in keywords.enumerated() {
                // Earlier keywords get higher weight
                let keywordWeight = 1.0 - (Double(index) / Double(keywords.count))
                
                // Check for matches in category name
                if categoryName.contains(keyword) {
                    score += 5.0 * keywordWeight
                }
                
                // Add weights for category usage - categories with more notes get a boost
                if category.notes.count > 0 {
                    score += min(Double(category.notes.count) * 0.1, 2.0)
                }
                
                // If the category has child categories, give it a slight boost
                // as it might be a better organizational fit
                if !category.childCategories.isEmpty {
                    score += 0.5
                }
            }
            
            categoryScores[category.id] = score
        }
        
        // Return the category with the highest score above a threshold
        if let (topCategoryId, score) = categoryScores.max(by: { $0.value < $1.value }), score > 3.0 {
            return categories.first { $0.id == topCategoryId }
        }
        
        return nil
    }
    
    /// Suggests tags based on content analysis
    func suggestTags(from text: String, existingTags: [Tag], userTags: [Tag]) -> [Tag] {
        guard !text.isEmpty else { return [] }
        
        // Extract keywords from the content
        let keywords = extractKeywords(from: text, maxKeywords: 15)
        
        // Get existing tag names for quick lookup
        let existingTagNames = Set(existingTags.map { $0.name.lowercased() })
        
        // Build a map of user tags for quick lookup
        let userTagMap = Dictionary(uniqueKeysWithValues: userTags.map { ($0.name.lowercased(), $0) })
        
        // Storage for tag suggestions
        var suggestedTags = [Tag]()
        
        // First, add existing user tags that match keywords
        for keyword in keywords {
            // Skip if already tagged
            if existingTagNames.contains(keyword.lowercased()) {
                continue
            }
            
            // Add exact matching tags
            if let matchingTag = userTagMap[keyword.lowercased()] {
                if !suggestedTags.contains(where: { $0.id == matchingTag.id }) {
                    suggestedTags.append(matchingTag)
                }
                continue
            }
            
            // Add tags that contain the keyword or vice versa
            for (tagName, tag) in userTagMap {
                if tagName.contains(keyword.lowercased()) || keyword.lowercased().contains(tagName) {
                    if !suggestedTags.contains(where: { $0.id == tag.id }) &&
                       !existingTagNames.contains(tagName) {
                        suggestedTags.append(tag)
                    }
                }
            }
        }
        
        // Then create suggestions for new tags from remaining keywords
        var potentialNewTags = [Tag]()
        for keyword in keywords {
            // Skip if the keyword is too short or is a stop word
            if keyword.count <= 3 || stopWords.contains(keyword.lowercased()) {
                continue
            }
            
            // Skip if this keyword is already used
            if existingTagNames.contains(keyword.lowercased()) ||
               suggestedTags.contains(where: { $0.name.lowercased() == keyword.lowercased() }) ||
               potentialNewTags.contains(where: { $0.name.lowercased() == keyword.lowercased() }) {
                continue
            }
            
            // Create a potential new tag
            let potentialTag = Tag(
                name: keyword.capitalized,
                colorHex: generateRandomColorHex(),
                createdAt: Date(),
                usageCount: 0,
                isAutoGenerated: true,
                confidenceScore: 0.8  // Set a reasonable confidence score
            )
            
            potentialNewTags.append(potentialTag)
            
            // Limit the number of new tag suggestions
            if potentialNewTags.count >= 3 {
                break
            }
        }
        
        // Combine existing and new tag suggestions, limited to a reasonable number
        let combined = suggestedTags + potentialNewTags
        let maxSuggestions = 5
        
        return Array(combined.prefix(maxSuggestions))
    }
    
    /// Generates a summary of the content
    func generateSummary(from text: String, maxLength: Int = 150) -> String? {
        guard text.count > 200 else { return nil }
        
        sentenceTagger.string = text
        let textRange = text.startIndex..<text.endIndex
        
        var sentences = [(String, Double)]()
        sentenceTagger.enumerateTags(in: textRange, unit: .paragraph, scheme: .lexicalClass) { _, sentenceRange in
            let sentence = String(text[sentenceRange])
            
            guard sentence.count > 15 else { return true }
            
            let importance = calculateSentenceImportance(sentence, fullText: text)
            sentences.append((sentence, importance))
            
            return true
        }
        
        // Sort sentences by importance
        let sortedSentences = sentences.sorted { $0.1 > $1.1 }
        
        var summary = ""
        for (sentence, _) in sortedSentences {
            if (summary + sentence).count <= maxLength {
                summary += sentence + " "
            } else {
                break
            }
        }
        
        if summary.count > maxLength {
            summary = String(summary.prefix(maxLength - 3)) + "..."
        }
        
        return summary.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Calculate a sentence's importance based on keywords and position
    private func calculateSentenceImportance(_ sentence: String, fullText: String) -> Double {
        // Extract keywords from the full text
        let keywords = extractKeywords(from: fullText, maxKeywords: 10)
        
        // Calculate importance based on keyword presence
        var importance = 0.0
        for keyword in keywords {
            if sentence.lowercased().contains(keyword.lowercased()) {
                importance += 1.0
            }
        }
        
        // Sentences at the beginning are usually more important (intro sentences)
        if fullText.prefix(sentence.count * 3).contains(sentence) {
            importance += 2.0
        }
        
        // Sentences containing specific marker phrases get a boost
        let importantPhrases = ["important", "key", "significant", "essential", "notable",
                               "in summary", "in conclusion", "to summarize"]
        
        for phrase in importantPhrases {
            if sentence.lowercased().contains(phrase) {
                importance += 1.5
                break  // Only count once
            }
        }
        
        return importance
    }
    
    /// Analyze text to identify the main topics and entities
    func analyzeContent(_ text: String) -> (keywords: [String], entities: [String], summary: String?) {
        // Extract keywords
        let keywords = extractKeywords(from: text)
        
        // Extract entities
        var entities = [String]()
        entityTagger.string = text
        let textRange = text.startIndex..<text.endIndex
        
        entityTagger.enumerateTags(in: textRange, unit: .word, scheme: .nameType) { tag, tokenRange in
            if let tag = tag, tag != .other {
                let entity = String(text[tokenRange])
                if !entities.contains(entity) && entity.count > 1 {
                    entities.append(entity)
                }
            }
            return true
        }
        
        // Generate summary
        let summary = generateSummary(from: text)
        
        return (keywords, entities, summary)
    }
    
    /// Generates a random color hex code
    private func generateRandomColorHex() -> String {
        let colors = [
            "#FF3B30", "#FF9500", "#FFCC00", "#34C759", "#5AC8FA",
            "#007AFF", "#5856D6", "#AF52DE", "#FF2D55", "#8E8E93"
        ]
        return colors[Int.random(in: 0..<colors.count)]
    }
}
