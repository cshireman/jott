//
//  FormattingToolbar.swift
//  Jott
//
//  Created by Chris Shireman on 5/16/25.
//

import SwiftUI

struct FormattingToolbar: View {
    let onFormatting: (FormattingStyle) -> Void
    let onToggleCheck: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                Button(action: { onFormatting(.bold) }) {
                    Image(systemName: "bold")
                }
                
                Button(action: { onFormatting(.italic) }) {
                    Image(systemName: "italic")
                }
                
                Button(action: { onFormatting(.heading) }) {
                    Image(systemName: "h.square")
                }
                
                Button(action: { onFormatting(.bulletList) }) {
                    Image(systemName: "list.bullet")
                }
                
                Button(action: { onFormatting(.numberedList) }) {
                    Image(systemName: "list.number")
                }
                
                Button(action: { onFormatting(.checkList) }) {
                    Image(systemName: "checklist")
                }
                
                Button(action: { onToggleCheck() }) {
                    Image(systemName: "checkmark.square")
                }
                
                Button(action: { onFormatting(.highlight) }) {
                    Image(systemName: "highlighter")
                }
                
                Button(action: { onFormatting(.link) }) {
                    Image(systemName: "link")
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.1))
    }
}
