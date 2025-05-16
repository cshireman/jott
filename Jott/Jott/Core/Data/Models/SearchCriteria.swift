//
//  SearchCriteria.swift
//  Jott
//
//  Created by Chris Shireman on 5/16/25.
//


// SearchCriteria.swift
import Foundation

struct SearchCriteria {
    let text: String
    let categoryIds: [UUID]
    let tagIds: [UUID]
    let recentOnly: Bool
    
    var hasFilters: Bool {
        return !text.isEmpty || !categoryIds.isEmpty || !tagIds.isEmpty || recentOnly
    }
}