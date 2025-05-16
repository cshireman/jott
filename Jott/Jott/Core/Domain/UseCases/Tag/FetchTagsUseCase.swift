//
//  FetchTagsUseCase.swift
//  Jott
//
//  Created by Chris Shireman on 5/15/25.
//

import Foundation

actor FetchTagsUseCase {
    @Injected(\.tagRepository) private var tagRepository: TagRepositoryProtocol
    
    func execute() async throws -> [Tag] {
        return try await tagRepository.fetchTags()
    }
    
    func executePopular(limit: Int = 10) async throws -> [Tag] {
        return try await tagRepository.fetchPopularTags(limit: limit)
    }
}
