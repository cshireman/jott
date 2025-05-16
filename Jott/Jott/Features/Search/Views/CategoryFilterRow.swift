import SwiftUI

struct CategoryFilterRow: View {
    let category: Category
    let allCategories: [Category]
    @Binding var selectedIds: Set<UUID>
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if let iconName = category.iconName {
                    Image(systemName: iconName)
                        .foregroundColor(categoryColor)
                        .frame(width: 24)
                }
                
                Text(category.name)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
                
                if hasChildren {
                    Button {
                        isExpanded.toggle()
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                toggleSelection()
            }
            
            if isExpanded && hasChildren {
                ForEach(childCategories) { child in
                    CategoryFilterRow(
                        category: child,
                        allCategories: allCategories,
                        selectedIds: $selectedIds
                    )
                    .padding(.leading, 20)
                }
            }
        }
    }
    
    private var isSelected: Bool {
        selectedIds.contains(category.id)
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
    
    private func toggleSelection() {
        if isSelected {
            selectedIds.remove(category.id)
        } else {
            selectedIds.insert(category.id)
        }
    }
}
