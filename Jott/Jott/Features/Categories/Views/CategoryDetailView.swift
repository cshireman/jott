import SwiftUI

struct CategoryDetailView: View {
    let category: Category
    
    var body: some View {
        List {
            Section("Notes") {
                ForEach(category.notes) { note in
                    NavigationLink(value: note) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.title)
                                .font(.headline)
                            
                            Text(note.content.prefix(100))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            if category.hasChildren {
                Section("Subcategories") {
                    ForEach(category.childCategories) { subcategory in
                        NavigationLink(value: subcategory) {
                            CategoryRow(category: subcategory)
                        }
                    }
                }
            }
        }
        .navigationTitle(category.name)
        .navigationDestination(for: Note.self) { note in
            NoteDetailView(noteId: note.id)
        }
    }
}
