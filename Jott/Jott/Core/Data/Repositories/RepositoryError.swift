//
//  RepositoryError.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//


// RepositoryError.swift in Core/Data/Repositories
import Foundation

enum RepositoryError: Error {
    case itemNotFound
    case invalidOperation
    case saveFailed
    case fetchFailed
    case deleteFailed
    case duplicateItem
    
    var localizedDescription: String {
        switch self {
        case .itemNotFound:
            return "The requested item could not be found."
        case .invalidOperation:
            return "The operation is not valid in the current state."
        case .saveFailed:
            return "Failed to save changes."
        case .fetchFailed:
            return "Failed to fetch data."
        case .deleteFailed:
            return "Failed to delete item."
        case .duplicateItem:
            return "An item with the same identifier already exists."
        }
    }
}