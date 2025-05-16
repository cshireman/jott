import SwiftUI

struct CategoryRow: View {
    let category: Category
    
    var body: some View {
        HStack {
            if let iconName = category.iconName {
                Image(systemName: iconName)
                    .foregroundColor(categoryColor)
                    .frame(width: 30, height: 30)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                
                if category.hasChildren {
                    Text("\(category.childCategories.count) subcategories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            

        }
        .padding(.vertical, 4)
    }
    
    private var categoryColor: Color {
        if let hexColor = category.colorHex, let color = Color(hex: hexColor) {
            return color
        }
        return .blue
    }
}
