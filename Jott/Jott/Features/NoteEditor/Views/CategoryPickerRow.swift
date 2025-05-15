//
//  CategoryRow.swift
//  Jott
//
//  Created by Chris Shireman on 5/15/25.
//
import SwiftUI

struct CategoryPickerRow: View {
    let category: Category
    let selectedCategory: Category?
    let allCategories: [Category]
    let onSelect: (Category) -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                onSelect(category)
            } label: {
                HStack {
                    if let iconName = category.iconName {
                        Image(systemName: iconName)
                            .foregroundColor(categoryColor)
                            .frame(width: 24)
                    }
                    
                    Text(category.name)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if selectedCategory?.id == category.id {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                    
                    if hasChildren {
                        Button {
                            isExpanded.toggle()
                        } label: {
                            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .contentShape(Rectangle())
            }
            .padding(.vertical, 8)
            
            // Child categories
            if isExpanded {
                ForEach(childCategories) { child in
                    CategoryPickerRow(
                        category: child,
                        selectedCategory: selectedCategory,
                        allCategories: allCategories,
                        onSelect: onSelect
                    )
                    .padding(.leading, 20)
                }
            }
        }
    }
    
    private var hasChildren: Bool {
        !childCategories.isEmpty
    }
    
    private var childCategories: [Category] {
        allCategories.filter { $0.parentCategory?.id == category.id }
    }
    
    private var categoryColor: Color {
        if let hexColor = category.colorHex, let color = Color(hex: hexColor) {
            return color
        }
        return .blue
    }
}
