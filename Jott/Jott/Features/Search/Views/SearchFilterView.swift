//
//  SearchFilterView.swift
//  Jott
//
//  Created by Chris Shireman on 5/16/25.
//


// SearchFilterView.swift
import SwiftUI

struct SearchFilterView: View {
    @Environment(\.dismiss) private var dismiss
    
    let categories: [Category]
    let tags: [Tag]
    
    @Binding var selectedCategories: Set<UUID>
    @Binding var selectedTags: Set<UUID>
    @Binding var showRecentOnly: Bool
    
    @State private var showTags = true
    @State private var showCategories = true
    
    var body: some View {
        NavigationStack {
            List {
                // Time filter section
                Section(header: Text("Time Filter")) {
                    Toggle("Show Recent Only (Last 7 Days)", isOn: $showRecentOnly)
                }
                
                // Categories section
                Section(header: sectionHeader(title: "Categories", isExpanded: showCategories)) {
                    if showCategories {
                        ForEach(categories.filter { $0.parentCategory == nil }) { category in
                            CategoryFilterRow(
                                category: category,
                                allCategories: categories,
                                selectedIds: $selectedCategories
                            )
                        }
                    }
                }
                
                // Tags section
                Section(header: sectionHeader(title: "Tags", isExpanded: showTags)) {
                    if showTags {
                        ForEach(tags.sorted(by: { $0.name < $1.name })) { tag in
                            TagFilterRow(
                                tag: tag,
                                isSelected: selectedTags.contains(tag.id),
                                onToggle: {
                                    if selectedTags.contains(tag.id) {
                                        selectedTags.remove(tag.id)
                                    } else {
                                        selectedTags.insert(tag.id)
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Search Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
    
    private func sectionHeader(title: String, isExpanded: Bool) -> some View {
        Button {
            if title == "Categories" {
                showCategories.toggle()
            } else if title == "Tags" {
                showTags.toggle()
            }
        } label: {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
