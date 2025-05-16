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
    @EnvironmentObject private var themeManager: AppThemeManager
    
    // Get repositories from DI
    @Injected(\.noteRepository) private var noteRepository
    @Injected(\.categoryRepository) private var categoryRepository
    @Injected(\.tagRepository) private var tagRepository
    
    var body: some View {
            TabView {
                NavigationStack {
                    HomeView()
                        .environmentObject(themeManager)
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                
                NavigationStack {
                    CategoriesView()
                        .environmentObject(themeManager)
                }
                .tabItem {
                    Label("Categories", systemImage: "folder")
                }
                
                NavigationStack {
                    SearchView()
                        .environmentObject(themeManager)
                }
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                
                NavigationStack {
                    SettingsView()
                        .environmentObject(themeManager)
                }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
            .preferredColorScheme(themeManager.colorScheme)
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
