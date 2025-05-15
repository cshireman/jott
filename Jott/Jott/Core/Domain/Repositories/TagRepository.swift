//
//  TagRepository.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//


import Foundation
import SwiftData

final class TagRepository: TagRepositoryProtocol {
    private let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    func fetchTags() async throws -> [Tag] {
        let context = ModelContext(container)
        
        let descriptor = FetchDescriptor<Tag>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        return try context.fetch(descriptor)
    }
    
    func fetchPopularTags(limit: Int) async throws -> [Tag] {
        let context = ModelContext(container)
        
        var descriptor = FetchDescriptor<Tag>(
            sortBy: [
                SortDescriptor(\.usageCount, order: .reverse),
                SortDescriptor(\.name)
            ]
        )
        descriptor.fetchLimit = limit
        
        return try context.fetch(descriptor)
    }
    
    func fetchTag(withId id: UUID) async throws -> Tag? {
        let context = ModelContext(container)
        
        let predicate = #Predicate<Tag> {
            $0.id == id
        }
        
        let descriptor = FetchDescriptor<Tag>(predicate: predicate)
        let tags = try context.fetch(descriptor)
        
        return tags.first
    }
    
    func fetchTag(withName name: String) async throws -> Tag? {
        let context = ModelContext(container)
        
        // Case-insensitive search for the tag name
        let predicate = #Predicate<Tag> {
            $0.name == name
        }
        
        let descriptor = FetchDescriptor<Tag>(predicate: predicate)
        let tags = try context.fetch(descriptor)
        
        return tags.first
    }
    
    func saveTag(_ tag: Tag) async throws {
        let context = ModelContext(container)
        
        // If this is a new tag that hasn't been inserted yet
        if tag.modelContext == nil {
            context.insert(tag)
        }
        
        try context.save()
    }
    
    func deleteTag(_ tag: Tag) async throws {
        let context = ModelContext(container)
        
        context.delete(tag)
        try context.save()
    }
    
    func mergeTag(_ sourceTag: Tag, into destinationTag: Tag) async throws {
        // Transfer all notes from source tag to destination tag
        for note in sourceTag.notes {
            if !destinationTag.notes.contains(where: { $0.id == note.id }) {
                destinationTag.notes.append(note)
                
                // Update the note's tags collection
                if let index = note.tags.firstIndex(where: { $0.id == sourceTag.id }) {
                    note.tags.remove(at: index)
                }
                if !note.tags.contains(where: { $0.id == destinationTag.id }) {
                    note.tags.append(destinationTag)
                }
            }
        }
        
        // Update usage count
        destinationTag.usageCount = destinationTag.notes.count
        
        // Delete the source tag
        try await deleteTag(sourceTag)
    }
}
