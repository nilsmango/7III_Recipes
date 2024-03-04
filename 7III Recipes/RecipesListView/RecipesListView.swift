//
//  MarkdownBrowserView.swift
//  MDRecipes
//
//  Created by Simon Lang on 16.03.23.
//

import SwiftUI

struct RecipesListView: View {
    @ObservedObject var fileManager: RecipesManager
    
    @State private var editMode: EditMode = .inactive
        
    var category: String
    
    var body: some View {
        //        NavigationStack {
        List {
            ForEach(fileManager.filterTheRecipes(string: "", ingredients: [], categories: category.isEmpty ? [] : [category], tags: [])) { recipe in
                NavigationLink(value: recipe) {
                    ListItemView(recipe: recipe)
                }
            }
            .onDelete { indexSet in
                fileManager.delete(at: indexSet, filteringCategory: category)
            }
        }
        .listStyle(.insetGrouped)
        .background(
            .gray
                .opacity(0.1)
        )
        .navigationTitle(Text(category.isEmpty ? "All" : category))
        .toolbar {
            if fileManager.filterTheRecipes(string: "", ingredients: [], categories: category.isEmpty ? [] : [category], tags: []).count > 1 {
                Menu {
                    Picker("Sorting", selection: $fileManager.sortingSelection) {
                        ForEach(Sorting.allCases) { sortCase in
                            if sortCase == .cooked {
                                Text("Times Cooked")
                            } else if sortCase == .time {
                                Text("Total Time")
                            } else {
                                Text(sortCase.rawValue.capitalized)
                            }
                        }
                    }
                }
            label: {
                Label("Sort by", systemImage: "arrow.up.arrow.down.circle")
                    .labelStyle(.iconOnly)
            }
            }
        }
        .environment(\.editMode, $editMode)
        .onChange(of: fileManager.sortingSelection) { _ in
            fileManager.sortRecipes()
        }
    }
}

#Preview {
    let fileManager = RecipesManager()
    fileManager.recipes = Recipe.sampleData
    
    return RecipesListView(fileManager: fileManager, category: "Main Course")
}
