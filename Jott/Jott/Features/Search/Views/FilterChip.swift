import SwiftUI

struct FilterChip: View {
    let label: String
    let iconName: String?
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            if let iconName = iconName {
                Image(systemName: iconName)
                    .font(.caption)
            }
            
            Text(label)
                .font(.caption)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 8))
                    .padding(2)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.blue.opacity(0.1))
        )
        .foregroundColor(.blue)
    }
}
