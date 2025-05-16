//
//  SearchView.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var showFilterSheet = false
    @State private var showNoteDetail = false
    @State private var selectedNoteId: UUID?
    @State private var isVisible = false
    
    var body: some View {
        
        VStack(spacing: 0) {
            // Search bar
            searchBar
            
            // Applied filters
            if !viewModel.selectedCategories.isEmpty || !viewModel.selectedTags.isEmpty || viewModel.showRecentOnly {
                appliedFiltersView
            }
            
            // Content
            ZStack {
                if viewModel.isSearching {
                    ProgressView()
                        .transition(.opacity)
                        .animation(.easeInOut, value: isVisible)
                } else if viewModel.searchText.isEmpty && !viewModel.selectedCategories.isEmpty && !viewModel.selectedTags.isEmpty && !viewModel.showRecentOnly {
                    // Empty initial state
                    VStack(spacing: 24) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            Text("Ready to search")
                                .font(.title2.bold())
                            
                            Text("Type in the search bar or use filters")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                    .animation(.easeInOut(duration: 0.3).delay(0.1), value: isVisible)
                } else if viewModel.searchResults.isEmpty {
                    // No results state
                    VStack(spacing: 24) {
                        Image(systemName: "questionmark")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            Text("No matches found")
                                .font(.title2.bold())
                            
                            Text("Try adjusting your search or filters")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                    .animation(.easeInOut(duration: 0.3).delay(0.1), value: isVisible)
                } else {
                    // Results list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.searchResults) { note in
                                SearchResultRow(note: note) {
                                    selectedNoteId = note.id
                                    showNoteDetail = true
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                    .animation(.easeInOut(duration: 0.3).delay(0.1), value: isVisible)
                }
            }
            
            // Recent searches
            if viewModel.searchText.isEmpty && !viewModel.recentSearches.isEmpty {
                recentSearchesView
            }
        }
        .navigationTitle("Search")
        .navigationDestination(isPresented: $showNoteDetail) {
            if let noteId = selectedNoteId {
                NoteDetailView(noteId: noteId)
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            SearchFilterView(
                categories: viewModel.availableCategories,
                tags: viewModel.availableTags,
                selectedCategories: $viewModel.selectedCategories,
                selectedTags: $viewModel.selectedTags,
                showRecentOnly: $viewModel.showRecentOnly
            )
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onChange(of: viewModel.selectedTags) { _, _ in
            Task {
                await viewModel.performSearch()
            }
        }
        .onChange(of: viewModel.selectedCategories) { _, _ in
            Task {
                await viewModel.performSearch()
            }
        }
        .onChange(of: viewModel.showRecentOnly) { _, _ in
            Task {
                await viewModel.performSearch()
            }
        }
        .onAppear {
            isVisible = true
        }
        .onDisappear {
            isVisible = false
        }
        
    }
    
    private var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search notes", text: $viewModel.searchText)
                    .disableAutocorrection(true)
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
            
            Button {
                showFilterSheet = true
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 22))
                    .foregroundColor(hasAppliedFilters ? .blue : .primary)
            }
        }
        .padding()
    }
    
    private var hasAppliedFilters: Bool {
        return !viewModel.selectedCategories.isEmpty || !viewModel.selectedTags.isEmpty || viewModel.showRecentOnly
    }
    
    private var appliedFiltersView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if viewModel.showRecentOnly {
                    FilterChip(label: "Recent", iconName: "clock") {
                        viewModel.showRecentOnly = false
                        Task {
                            await viewModel.performSearch()
                        }
                    }
                }
                
                ForEach(viewModel.availableCategories.filter { viewModel.selectedCategories.contains($0.id) }) { category in
                    FilterChip(label: category.name, iconName: category.iconName) {
                        viewModel.toggleCategory(category.id)
                    }
                }
                
                ForEach(viewModel.availableTags.filter { viewModel.selectedTags.contains($0.id) }) { tag in
                    FilterChip(label: tag.name, iconName: "tag") {
                        viewModel.toggleTag(tag.id)
                    }
                }
                
                if hasAppliedFilters {
                    Button {
                        viewModel.selectedCategories.removeAll()
                        viewModel.selectedTags.removeAll()
                        viewModel.showRecentOnly = false
                        Task {
                            await viewModel.performSearch()
                        }
                    } label: {
                        Text("Clear All")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding(.leading, 8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .overlay(
            Divider(),
            alignment: .bottom
        )
    }
    
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recent Searches")
                    .font(.headline)
                
                Spacer()
                
                Button("Clear") {
                    viewModel.clearRecentSearches()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            ForEach(viewModel.recentSearches, id: \.self) { search in
                Button {
                    viewModel.useRecentSearch(search)
                } label: {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Text(search)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.left")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                Divider()
                    .padding(.leading)
            }
        }
        .padding(.top)
        .background(Color(.systemBackground))
        .overlay(
            Divider(),
            alignment: .top
        )
    }
}
