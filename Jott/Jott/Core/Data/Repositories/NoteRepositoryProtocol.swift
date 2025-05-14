//
//  NoteRepositoryProtocol.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//


import Foundation

protocol NoteRepositoryProtocol {
    func fetchNotes() async throws -> [Note]
    func fetchNotes(matching query: String) async throws -> [Note]
    func fetchNotes(inCategory categoryId: UUID?) async throws -> [Note]
    func fetchNotes(withTag tagId: UUID) async throws -> [Note]
    func fetchRecentNotes(limit: Int) async throws -> [Note]
    func fetchPinnedNotes() async throws -> [Note]
    func fetchNote(withId id: UUID) async throws -> Note?
    func saveNote(_ note: Note) async throws
    func deleteNote(_ note: Note) async throws
    func updateNoteML(noteId: UUID, summary: String?, keyEntities: [String]?) async throws
}
