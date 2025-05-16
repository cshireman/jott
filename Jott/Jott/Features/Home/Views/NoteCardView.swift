//
//  NoteCardView.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//

import SwiftUI

struct NoteCardView: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.title)
                .font(.headline)
                .lineLimit(1)
                .foregroundColor(.primary)
            
            Text(note.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            HStack {
                if let category = note.category {
                    CategoryPill(category: category)
                }
                
                Spacer()
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1).gradient)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: note.updatedAt)
    }
}

#Preview {
    let note = Note(
        id: UUID(),
        title: "Sample Note",
        content:
            """
            Q1 Goals:
            - Implement new authentication system
            - Refactor legacy code
            - Improve test coverage to 80%
            
            Q2 Goals:
            - Launch v2.0 of the app
            - Add analytics dashboard
            - Start work on iOS widget
            """,
        updatedAt: Date()
    )
    
    NoteCardView(note: note)
        .padding()
}
