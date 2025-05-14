//
//  RepositoryKeys.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//

import Foundation
import SwiftData

// Note Repository Key
@MainActor
struct NoteRepositoryKey: @preconcurrency InjectionKey {
    static var currentValue: NoteRepositoryProtocol = NoteRepository(container: ModelContainerHelper.shared.container)
}

// Category Repository Key
@MainActor
struct CategoryRepositoryKey: @preconcurrency InjectionKey {
    static var currentValue: CategoryRepositoryProtocol = CategoryRepository(container: ModelContainerHelper.shared.container)
}

// Tag Repository Key
@MainActor
struct TagRepositoryKey: @preconcurrency InjectionKey {
    static var currentValue: TagRepositoryProtocol = TagRepository(container: ModelContainerHelper.shared.container)
}

// User Preferences Repository Key
@MainActor
struct UserPreferencesRepositoryKey: @preconcurrency InjectionKey {
    static var currentValue: UserPreferencesRepositoryProtocol = UserPreferencesRepository()
}
