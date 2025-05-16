import SwiftUI

struct CategoryEditorView: View {
    let category: Category?
    let onSave: (Category) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var iconName = ""
    @State private var colorHex = ""
    @StateObject private var viewModel = CategoriesViewModel()
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                
                HStack {
                    TextField("Icon", text: $iconName)
                    if !iconName.isEmpty {
                        Image(systemName: iconName)
                            .foregroundColor(selectedColor)
                    }
                }
                
                ColorPicker("Color", selection: Binding(
                    get: { Color(hex: colorHex) ?? .blue },
                    set: { colorHex = $0.toHex() ?? "" }
                ))
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
                    onSave(newCategory)
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
        }
        .onAppear {
            if let category = category {
                name = category.name
                iconName = category.iconName ?? ""
                colorHex = category.colorHex ?? ""
            }
            viewModel.loadCategories()
        }
    }
    
    private var selectedColor: Color {
        Color(hex: colorHex) ?? .blue
    }
}
