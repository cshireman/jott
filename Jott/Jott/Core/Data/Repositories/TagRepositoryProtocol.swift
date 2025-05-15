//
//  TagRepositoryProtocol.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//


import Foundation

protocol TagRepositoryProtocol: Sendable {
    func fetchTags() async throws -> [Tag]
    func fetchPopularTags(limit: Int) async throws -> [Tag]
    func fetchTag(withId id: UUID) async throws -> Tag?
    func fetchTag(withName name: String) async throws -> Tag?
    func saveTag(_ tag: Tag) async throws
    func deleteTag(_ tag: Tag) async throws
    func mergeTag(_ sourceTag: Tag, into destinationTag: Tag) async throws
}
