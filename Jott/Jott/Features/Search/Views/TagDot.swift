import SwiftUI

struct TagDot: View {
    let tag: Tag
    
    var body: some View {
        Circle()
            .fill(tagColor)
            .frame(width: 8, height: 8)
    }
    
    private var tagColor: Color {
        if let hexColor = tag.colorHex, let color = Color(hex: hexColor) {
            return color
        }
        return .blue
    }
}

