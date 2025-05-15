//
//  TagView.swift
//  Jott
//
//  Created by Chris Shireman on 5/15/25.
//
import SwiftUI

struct TagView: View {
    let tag: Tag
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag.name)
                .font(.caption)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 8))
                    .padding(2)
            }
        }
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
