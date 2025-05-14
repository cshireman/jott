//
//  Note.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//

import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var isPinned: Bool
    
    @Relationship(.unique, deleteRule: .nullify, inverse: \Tag.notes)
    var tags: [Tag] = []
    
    @Relationship(.unique, deleteRule: .nullify, inverse: \Category.notes)
    var category: Category?
    
    // Derived properties for ML features
    var summary: String?
    var keyEntities: [String]?
    
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isPinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPinned = isPinned
    }
}
