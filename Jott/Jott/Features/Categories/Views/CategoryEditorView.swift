import SwiftUI

struct CategoryEditorView: View {
    let category: Category?
    let onSave: (Category) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var iconName: String = ""
    @State private var colorHex: String = ""
    @State private var parentCategoryId: UUID?
    @State private var showIconPicker = false
    @StateObject private var viewModel = CategoriesViewModel()
    
    // Common SF Symbols for categories
    private let icons = [
        "folder", "folder.fill",
        "doc", "doc.fill",
        "tray", "tray.fill",
        "star", "star.fill",
        "heart", "heart.fill",
        "flag", "flag.fill",
        "tag", "tag.fill",
        "bookmark", "bookmark.fill",
        "paperclip",
        "link", "link.circle.fill",
        "person", "person.fill",
        "house", "house.fill",
        "briefcase", "briefcase.fill",
        "calendar", "calendar.badge.plus",
        "book", "book.fill",
        "list.bullet", "list.dash",
        "checkmark.circle", "checkmark.circle.fill",
        "pencil", "pencil.circle.fill",
        "trash", "trash.fill",
        "gear", "gearshape.fill",
        "bell", "bell.fill",
        "clock", "clock.fill",
        "lightbulb", "lightbulb.fill",
        "pin", "pin.fill",
        "bubble.left", "bubble.left.fill",
        "envelope", "envelope.fill",
        "cart", "cart.fill",
        "creditcard", "creditcard.fill"
    ]
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                
                HStack {
                    if !iconName.isEmpty {
                        Image(systemName: iconName)
                            .foregroundColor(Color(hex: colorHex) ?? .blue)
                            .font(.title2)
                    }
                    
                    Button(action: { showIconPicker = true }) {
                        HStack {
                            Text(iconName.isEmpty ? "Choose Icon" : "Change Icon")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                ColorPicker("Color", selection: Binding(
                    get: { Color(hex: colorHex) ?? .blue },
                    set: { colorHex = $0.toHex() ?? "" }
                ))
                
                if category == nil {  // Only show for new categories
                    Picker("Parent Category", selection: $parentCategoryId) {
                        Text("None").tag(nil as UUID?)
                        ForEach(viewModel.categories) { category in
                            Text(category.name).tag(category.id as UUID?)
                        }
                    }
                }
            }
        }
        .navigationTitle(category == nil ? "New Category" : "Edit Category")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let newCategory = Category(
                        id: category?.id ?? UUID(),
                        name: name,
                        iconName: iconName.isEmpty ? nil : iconName,
                        colorHex: colorHex.isEmpty ? nil : colorHex
                    )
                    
                    // Set parent category if selected
                    if let parentId = parentCategoryId,
                       let parentCategory = viewModel.categories.first(where: { $0.id == parentId }) {
                        newCategory.parentCategory = parentCategory
                        parentCategory.childCategories.append(newCategory)
                    }
                    
                    onSave(newCategory)
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
        }
        .sheet(isPresented: $showIconPicker) {
            NavigationStack {
                List {
                    ForEach(0..<icons.count/2, id: \.self) { row in
                        let index = row * 2
                        HStack(spacing: 20) {
                            ForEach(0..<2) { col in
                                let iconIndex = index + col
                                if iconIndex < icons.count {
                                    Button {
                                        iconName = icons[iconIndex]
                                        showIconPicker = false
                                    } label: {
                                        HStack {
                                            Image(systemName: icons[iconIndex])
                                                .font(.title2)
                                                .frame(width: 30)
                                                .foregroundColor(Color(hex: colorHex) ?? .blue)
                                            
                                            Text(icons[iconIndex])
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            if icons[iconIndex] == iconName {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        .padding(.vertical, 8)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Choose Icon")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showIconPicker = false
                        }
                    }
                }
            }
        }
        .onAppear {
            if let category = category {
                name = category.name
                iconName = category.iconName ?? ""
                colorHex = category.colorHex ?? ""
                parentCategoryId = category.parentCategory?.id
            }
            viewModel.loadCategories()
        }
    }
}
