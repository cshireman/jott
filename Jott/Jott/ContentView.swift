//
//  ContentView.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Get repositories from DI
    @Injected(\.noteRepository) private var noteRepository
    @Injected(\.categoryRepository) private var categoryRepository
    @Injected(\.tagRepository) private var tagRepository
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "folder")
                }
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            // Check for and generate mock data if needed
            checkAndGenerateMockData()
        }
    }
    
    private func checkAndGenerateMockData() {
        // Check if we already have data
        var descriptor = FetchDescriptor<Note>()
        descriptor.fetchLimit = 1
        
        if let count = try? modelContext.fetchCount(descriptor), count == 0 {
            // No existing data, generate mock data
            MockDataGenerator.createMockData(in: modelContext)
        }
    }
}
