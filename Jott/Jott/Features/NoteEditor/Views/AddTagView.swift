//
//  AddTagView.swift
//  Jott
//
//  Created by Chris Shireman on 5/15/25.
//
import SwiftUI

struct AddTagView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var tagName = ""
    @State private var selectedColor = Color.blue
    @FocusState private var isTagNameFocused: Bool
    
    let onSubmit: (String, String?) -> Void
    
    private let colorOptions: [Color] = [
        .red, .orange, .yellow, .green, .blue, .indigo, .purple, .pink
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Tag Name", text: $tagName)
                        .focused($isTagNameFocused)
                }
                
                Section(header: Text("Tag Color")) {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 44))
                    ], spacing: 10) {
                        ForEach(colorOptions, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: color == selectedColor ? 2 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button("Create Tag") {
                        let hexColor = selectedColor.toHex()
                        onSubmit(tagName, hexColor)
                        dismiss()
                    }
                    .disabled(tagName.isEmpty)
                }
            }
            .navigationTitle("New Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isTagNameFocused = true
            }
        }
    }
}
