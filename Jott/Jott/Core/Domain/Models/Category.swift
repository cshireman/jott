//
//  Category.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//


import Foundation
import SwiftData

@Model
final class Category: @unchecked Sendable {
    // Core properties
    var id: UUID
    var name: String
    var iconName: String?  // SF Symbol name
    var colorHex: String?  // Hex color code
    
    // Metadata
    var createdAt: Date
    var updatedAt: Date
    var isDefault: Bool    // Is this a system-provided default category?
    var sortOrder: Int     // For custom ordering in UI
    
    // ML-related properties
    var isAutoGenerated: Bool  // Was this category suggested by ML?
    
    // Relationships
    @Relationship(deleteRule: .nullify)
    var notes: [Note] = []
    
    // Optional parent-child relationship for hierarchical tags
    @Relationship(deleteRule: .nullify)
    var parentCategory: Category?
    
    @Relationship(.unique, deleteRule: .nullify)
    var childCategories: [Category] = []
    
    init(
        id: UUID = UUID(),
        name: String,
        iconName: String? = nil,
        colorHex: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isDefault: Bool = false,
        sortOrder: Int = 0,
        isAutoGenerated: Bool = false
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDefault = isDefault
        self.sortOrder = sortOrder
        self.isAutoGenerated = isAutoGenerated
    }
}

extension Category {
    
    // Check if category has children
    var hasChildren: Bool {
        !childCategories.isEmpty
    }
    
    // Get all descendant categories (recursive)
    var allDescendants: [Category] {
        var descendants: [Category] = []
        for child in childCategories {
            descendants.append(child)
            descendants.append(contentsOf: child.allDescendants)
        }
        return descendants
    }
    
    // Get category path (e.g., "Work > Projects > Personal")
    var path: String {
        var components: [String] = [self.name]
        var current = self
        
        while let parent = current.parentCategory {
            components.insert(parent.name, at: 0)
            current = parent
        }
        
        return components.joined(separator: " > ")
    }
}

// Create default categories
extension Category {
    static func createDefaultCategories(context: ModelContext) {
        let defaults = [
            Category(name: "Inbox", iconName: "tray", colorHex: "#007AFF", isDefault: true, sortOrder: 0),
            Category(name: "Personal", iconName: "person", colorHex: "#FF9500", isDefault: true, sortOrder: 1),
            Category(name: "Work", iconName: "briefcase", colorHex: "#FF2D55", isDefault: true, sortOrder: 2),
            Category(name: "Ideas", iconName: "lightbulb", colorHex: "#5856D6", isDefault: true, sortOrder: 3),
            Category(name: "Tasks", iconName: "checklist", colorHex: "#34C759", isDefault: true, sortOrder: 4)
        ]
        
        for category in defaults {
            context.insert(category)
        }
        
        try? context.save()
    }
}
