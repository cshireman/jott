//
//  SettingsView.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//

// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var showAnalysisProgress = false
    @State private var analysisProgress = 0.0
    @State private var showDefaultCategoryPicker = false
    
    var body: some View {
        
        Form {
            // Appearance section
            Section(header: Text("Appearance")) {
                Picker("Theme", selection: $viewModel.colorScheme) {
                    Text("System Default").tag(nil as ColorScheme?)
                    Text("Light").tag(ColorScheme.light as ColorScheme?)
                    Text("Dark").tag(ColorScheme.dark as ColorScheme?)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: viewModel.colorScheme) { _, _ in
                    viewModel.saveColorScheme()
                }
            }
            
            // AI Features section
            Section(header: Text("AI Features")) {
                Toggle("Auto Tagging", isOn: $viewModel.enableAutoTagging)
                    .onChange(of: viewModel.enableAutoTagging) { _, _ in
                        viewModel.saveAutoTagging()
                    }
                
                Toggle("Auto Summarization", isOn: $viewModel.enableAutoSummarization)
                    .onChange(of: viewModel.enableAutoSummarization) { _, _ in
                        viewModel.saveAutoSummarization()
                    }
                
                Toggle("Related Notes", isOn: $viewModel.enableRelatedNotes)
                    .onChange(of: viewModel.enableRelatedNotes) { _, _ in
                        viewModel.saveRelatedNotes()
                    }
                
                Button {
                    runContentAnalysis()
                } label: {
                    Text("Analyze All Notes")
                }
                .disabled(viewModel.isLoading)
            }
            
            // Note Defaults section
            Section(header: Text("Note Defaults")) {
                HStack {
                    Text("Default Category")
                    Spacer()
                    Button {
                        showDefaultCategoryPicker = true
                    } label: {
                        HStack {
                            if let defaultId = viewModel.defaultCategoryId,
                               let category = viewModel.availableCategories.first(where: { $0.id == defaultId }) {
                                Text(category.name)
                                    .foregroundColor(.primary)
                            } else {
                                Text("None")
                                    .foregroundColor(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Stats section
            Section(header: Text("Stats")) {
                HStack {
                    Text("Notes")
                    Spacer()
                    Text("\(viewModel.totalNotes)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Categories")
                    Spacer()
                    Text("\(viewModel.totalCategories)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Tags")
                    Spacer()
                    Text("\(viewModel.totalTags)")
                        .foregroundColor(.secondary)
                }
            }
            
            // About section
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .overlay {
            if showAnalysisProgress {
                ZStack {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        ProgressView(value: analysisProgress, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(width: 200)
                        
                        Text("Analyzing notes...")
                            .font(.headline)
                        
                        Text("\(Int(analysisProgress * 100))%")
                            .font(.subheadline)
                        
                        Button("Cancel") {
                            showAnalysisProgress = false
                        }
                        .padding(.top)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                    )
                    .shadow(radius: 10)
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
        .sheet(isPresented: $showDefaultCategoryPicker) {
            CategoryPickerView(
                selectedCategory: viewModel.availableCategories.first(where: { $0.id == viewModel.defaultCategoryId }),
                onSelectCategory: { category in
                    viewModel.defaultCategoryId = category?.id
                    viewModel.saveDefaultCategory()
                }
            )
        }
        
    }
    
    private func runContentAnalysis() {
        showAnalysisProgress = true
        analysisProgress = 0.0
        
        Task {
            let count = await viewModel.runContentAnalysis { progress in
                analysisProgress = progress
            }
            
            showAnalysisProgress = false
            
            // Show success message
        }
    }
}
