//
//  ContentAnalysisService.swift
//  Jott
//
//  Created by Chris Shireman on 5/16/25.
//


import Foundation

actor ContentAnalysisService {
    private let textAnalysisService = TextAnalysisService()
    
    @Injected(\.noteRepository) private var noteRepository: NoteRepositoryProtocol
    
    /// Analyzes all notes to generate summaries and extract key entities
    func analyzeAllNotes(progressCallback: @MainActor (Double) -> Void) async throws -> Int {
        let notes = try await noteRepository.fetchNotes()
        var processedCount = 0
        
        for (index, note) in notes.enumerated() {
            // Skip notes that are too short
            guard note.content.count > 200 else {
                await progressCallback(Double(index) / Double(notes.count))
                continue
            }
            
            // Analyze content
            let analysis = await textAnalysisService.analyzeContent(note.content)
            
            // Update note properties
            try await noteRepository.updateNoteML(
                noteId: note.id,
                summary: analysis.summary,
                keyEntities: analysis.keywords
            )
            
            // Update progress
            processedCount += 1
            await progressCallback(Double(index + 1) / Double(notes.count))
        }
        
        return processedCount
    }
    
    /// Analyzes a specific note and returns the analysis results
    func analyzeNote(noteId: UUID) async throws -> (summary: String?, keywords: [String], entities: [String]) {
        guard let note = try await noteRepository.fetchNote(withId: noteId) else {
            throw NSError(domain: "com.jott.error", code: 404, userInfo: [NSLocalizedDescriptionKey: "Note not found"])
        }
        
        // Analyze content
        let analysis = await textAnalysisService.analyzeContent(note.content)
        
        // Update note properties
        try await noteRepository.updateNoteML(
            noteId: note.id,
            summary: analysis.summary,
            keyEntities: analysis.keywords
        )
        
        return (analysis.summary, analysis.keywords, analysis.entities)
    }
    
    /// Suggests related notes based on content similarity
    func findRelatedNotes(forNoteId noteId: UUID, limit: Int = 5) async throws -> [Note] {
        guard let note = try await noteRepository.fetchNote(withId: noteId) else {
            throw NSError(domain: "com.jott.error", code: 404, userInfo: [NSLocalizedDescriptionKey: "Note not found"])
        }
        
        // Get all notes except the current one
        let allNotes = try await noteRepository.fetchNotes()
        let otherNotes = allNotes.filter { $0.id != noteId }
        
        // Extract keywords from the source note
        let sourceKeywords = await textAnalysisService.extractKeywords(from: note.content, maxKeywords: 20)
        
        // Calculate similarity scores
        var noteScores = [(note: Note, score: Double)]()
        
        for otherNote in otherNotes {
            let otherKeywords = await textAnalysisService.extractKeywords(from: otherNote.content, maxKeywords: 20)
            
            // Calculate keyword overlap
            var score = 0.0
            for keyword in sourceKeywords {
                if otherKeywords.contains(where: { $0.lowercased() == keyword.lowercased() }) {
                    score += 1.0
                }
            }
            
            // Add tag similarity
            let sourceTagIds = Set(note.tags.map { $0.id })
            let otherTagIds = Set(otherNote.tags.map { $0.id })
            let tagOverlap = sourceTagIds.intersection(otherTagIds).count
            score += Double(tagOverlap) * 2.0
            
            // Add category similarity
            if note.category?.id == otherNote.category?.id && note.category != nil {
                score += 3.0
            }
            
            noteScores.append((otherNote, score))
        }
        
        // Sort by score and return top results
        let relatedNotes = noteScores.sorted { $0.score > $1.score }
            .prefix(limit)
            .map { $0.note }
        
        return Array(relatedNotes)
    }
}
