//
//  TagRow.swift
//  Jott
//
//  Created by Chris Shireman on 5/15/25.
//
import SwiftUI

struct TagPickerRow: View {
    let tag: Tag
      let isSelected: Bool
      let onSelect: () -> Void
      
      var body: some View {
          Button {
              onSelect()
          } label: {
              HStack {
                  Text(tag.name)
                      .foregroundColor(.primary)
                  
                  Spacer()
                  
                  if isSelected {
                      Image(systemName: "checkmark")
                          .foregroundColor(.blue)
                  }
                  
                  // Usage count badge
                  if tag.usageCount > 0 {
                      Text("\(tag.usageCount)")
                          .font(.caption2)
                          .padding(.horizontal, 6)
                          .padding(.vertical, 2)
                          .background(Color.secondary.opacity(0.2))
                          .clipShape(Capsule())
                  }
              }
          }
          .foregroundColor(tagColor)
      }
      
      private var tagColor: Color {
          if let hexColor = tag.colorHex, let color = Color(hex: hexColor) {
              return color
          }
          return .blue
      }
}
