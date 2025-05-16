//
//  CategoriesView.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//


import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel = CategoriesViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                List {
                    ForEach(viewModel.categories) { category in
                        CategoryRow(category: category)
                    }
                }
            }
        }
        .navigationTitle("Categories")
        .onAppear {
            viewModel.loadCategories()
        }
    }
}

struct CategoryRow: View {
    let category: Category
    
    var body: some View {
        HStack {
            if let iconName = category.iconName {
                Image(systemName: iconName)
                    .foregroundColor(categoryColor)
                    .frame(width: 30, height: 30)
            }
            
            VStack(alignment: .leading) {
                Text(category.name)
                    .font(.headline)
                
                if !category.childCategories.isEmpty {
                    Text("\(category.childCategories.count) subcategories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(.vertical, 4)
    }
    
    private var categoryColor: Color {
        if let hexColor = category.colorHex, let color = Color(hex: hexColor) {
            return color
        }
        return .blue
    }
}
