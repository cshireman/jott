//
//  CategoryRow.swift
//  Jott
//
//  Created by Chris Shireman on 5/15/25.
//
import SwiftUI

struct CategoryPickerRow: View {
    let item: CategoryListItem
    let selectedCategory: Category?
    let allCategories: [Category]
    
    @State private var isExpanded = false
    
    var body: some View {
        HStack {
            if let iconName = item.category?.iconName {
                Image(systemName: iconName)
                    .foregroundColor(categoryColor)
                    .frame(width: 24)
            }
            
            Text(item.name)
                .foregroundColor(.primary)
            
            Spacer()
            
            if selectedCategory?.id == item.category?.id {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
    }
    
    private var children: [Category] {
        allCategories.filter { $0.parentCategory?.id == item.category?.id }
    }
    
    private var categoryColor: Color {
        if let hexColor = item.category?.colorHex, let color = Color(hex: hexColor) {
            return color
        }
        return .blue
    }
}
