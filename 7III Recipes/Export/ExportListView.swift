//
//  ExportListView.swift
//  7III Recipes
//
//  Created by Simon Lang on 28.02.2024.
//

import SwiftUI

struct ExportListView: View {
    @ObservedObject var recipesManager: RecipesManager

    @State private var searchText = ""
    
    @State private var selectedRecipes: [Recipe] = []
    
    @State private var showExportOverlay = false

    var body: some View {
        List {
            ForEach(recipesManager.getAllCategories(), id: \.self) { category in
                if !recipesManager.filterTheRecipes(string: searchText, ingredients: [], categories: [category], tags: []).isEmpty {
                    Section {
                        ForEach(recipesManager.filterTheRecipes(string: searchText, ingredients: [], categories: [category], tags: [])) { recipe in
                            let recipeSelected = selectedRecipes.contains(recipe)
                            
                            HStack {
                                Image(systemName: recipeSelected ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(recipeSelected ? .blue : .primary)
                                
                                ListItemView(recipe: recipe)
                                
                                Spacer(minLength: 0.0)
                            }
//                            .padding(.horizontal)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if recipeSelected {
                                    selectedRecipes.removeAll(where: { $0 == recipe })
                                } else {
                                    selectedRecipes.append(recipe)
                                }
                            }
                            
                                
                        }
                    } header: {
                        Text(category)
                            .font(.title3)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                    }
                }
            }
        }
        .overlay {
            if showExportOverlay {
                ExportRecipesOverlay(recipesManager: recipesManager, showExportOverlay: $showExportOverlay, recipes: selectedRecipes)
            } else {
                ExportOverlayButton(onExport: {
                    showExportOverlay = true
                })
                    .disabled(selectedRecipes.isEmpty)
            }
        }
        .background(
            .gray.opacity(0.1)
            )
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .scrollContentBackground(.hidden)
        .navigationTitle("Select Recipes")
        
//        .background(ignoresSafeAreaEdges: .all)
    }
}

#Preview {
    ExportListView(recipesManager: RecipesManager())
}
