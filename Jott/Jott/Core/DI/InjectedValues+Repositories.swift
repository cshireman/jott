//
//  InjectedValues+Repositories.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//

import Foundation
import SwiftData

extension InjectedValues {
    var noteRepository: NoteRepositoryProtocol {
        get { Self[NoteRepositoryKey.self] }
        set { Self[NoteRepositoryKey.self] = newValue }
    }
    
    var categoryRepository: CategoryRepositoryProtocol {
        get { Self[CategoryRepositoryKey.self] }
        set { Self[CategoryRepositoryKey.self] = newValue }
    }
    
    var tagRepository: TagRepositoryProtocol {
        get { Self[TagRepositoryKey.self] }
        set { Self[TagRepositoryKey.self] = newValue }
    }
    
    var userPreferencesRepository: UserPreferencesRepositoryProtocol {
        get { Self[UserPreferencesRepositoryKey.self] }
        set { Self[UserPreferencesRepositoryKey.self] = newValue }
    }
}
