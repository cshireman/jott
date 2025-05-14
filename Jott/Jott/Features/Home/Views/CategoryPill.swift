//
//  CategoryPill.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//


import SwiftUI

struct CategoryPill: View {
    let category: Category
    
    var body: some View {
        HStack(spacing: 4) {
            if let iconName = category.iconName {
                Image(systemName: iconName)
                    .font(.caption)
            }
            
            Text(category.name)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(categoryColor.opacity(0.2))
        .foregroundColor(categoryColor)
        .cornerRadius(8)
    }
    
    private var categoryColor: Color {
        if let hexColor = category.colorHex, let color = Color(hex: hexColor) {
            return color
        }
        return .blue
    }
}