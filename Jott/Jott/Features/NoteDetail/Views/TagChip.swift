//
//  TagChip.swift
//  Jott
//
//  Created by Chris Shireman on 5/15/25.
//
import SwiftUI

struct TagChip: View {
    let tag: Tag
    
    var body: some View {
        Text(tag.name)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(tagColor.opacity(0.2))
            )
            .foregroundColor(tagColor)
    }
    
    private var tagColor: Color {
        if let hexColor = tag.colorHex, let color = Color(hex: hexColor) {
            return color
        }
        return .blue
    }
}
