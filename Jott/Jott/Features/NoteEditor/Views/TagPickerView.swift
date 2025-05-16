//
//  TagPickerView.swift
//  Jott
//
//  Created by Chris Shireman on 5/15/25.
//


import SwiftUI

struct TagPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TagPickerViewModel()
    @State private var showAddTagSheet = false
    @State private var newTagName = ""
    
    let selectedTags: [Tag]
    let onSelectTag: (Tag) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    VStack(spacing: 0) {
                        // Search bar
                        SearchBarView(text: $viewModel.searchText, placeholder: "Search Tags")
                            .padding()
                            .onChange(of: viewModel.searchText) { _, _ in
                                viewModel.updateFilteredTags()
                            }
                        
                        Divider()
                        
                        // Popular tags (only show if not searching)
                        if viewModel.searchText.isEmpty && !viewModel.getPopularTags().isEmpty {
                            popularTagsSection
                        }
                        
                        // All tags
                        allTagsView
                    }
                }
            }
            .navigationTitle("Select Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .sheet(isPresented: $showAddTagSheet) {
                AddTagView { tagName, colorHex in
                    if !tagName.isEmpty {
                        Task {
                            if let newTag = await viewModel.createTag(name: tagName, colorHex: colorHex) {
                                onSelectTag(newTag)
                                dismiss()
                            }
                        }
                    }
                }
            }
            .task {
                await viewModel.loadTags()
            }
        }
    }
    
    private var allTagsView: some View {
        List {
            Section {
                Button {
                    showAddTagSheet = true
                } label: {
                    Label("Create New Tag", systemImage: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            Section(header: Text("All Tags")) {
                if viewModel.filteredTags.isEmpty {
                    Text("No tags found")
                        .foregroundColor(.secondary)
                        .italic()
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.filteredTags) { tag in
                        TagPickerRow(
                            tag: tag,
                            isSelected: selectedTags.contains(where: { $0.id == tag.id }),
                            onSelect: {
                                onSelectTag(tag)
                                dismiss()
                            }
                        )
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private var popularTagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Popular Tags")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 8)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.getPopularTags()) { tag in
                        Button {
                            onSelectTag(tag)
                            dismiss()
                        } label: {
                            HStack {
                                Text(tag.name)
                                Text("\(tag.usageCount)")
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.secondary.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(tagColor(tag).opacity(0.2))
                            )
                            .foregroundColor(tagColor(tag))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 8)
            
            Divider()
        }
    }
    
    private func tagColor(_ tag: Tag) -> Color {
        if let hexColor = tag.colorHex, let color = Color(hex: hexColor) {
            return color
        }
        return .blue
    }
}

