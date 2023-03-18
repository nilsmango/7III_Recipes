//
//  FilterTesting.swift
//  MDRecipes
//
//  Created by Simon Lang on 17.03.23.
//

import SwiftUI

struct FilterTesting: View {
    @ObservedObject var fileManager: MarkdownFileManager
    
    @State private var searchText = ""
   
    @State private var activeIngredients = [String]()
    
    @State private var activeCategories = [String]()
    
    private func isSelected(button: String) -> Bool {
        if activeIngredients.contains(button) || activeCategories.contains(button) {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(fileManager.filterTheRecipes(string: searchText, ingredients: activeIngredients, categories: activeCategories)) { recipe in
                    NavigationLink(destination: RecipeView(recipe: recipe)) {
                        ListItemView(recipe: recipe)
                    }
                }
                
            }
            
            HStack {
                
                ForEach(fileManager.getAllIngredients(), id: \.self) { ingredient in
                    
                    Button(action: {
                        // TODO: make a func for this
                        if isSelected(button: ingredient) {
                            activeIngredients.removeAll(where: { $0 == ingredient })
                        } else {
                            activeIngredients.append(ingredient)
                        }
                        
                    }) {
                        
                            
                        if isSelected(button: ingredient) {
                            Text(ingredient)
                                .fixedSize()
                            
                                
                        } else {
                            Text(ingredient)
                                .fixedSize()
                                .foregroundColor(.secondary)
                        }
                        }
                    
                    .buttonStyle(.bordered)
                            
                    
               
        }
            }
            
            HStack {
                
                ForEach(fileManager.getAllCategories(), id: \.self) { category in
                    
                    Button(action: {
                        // TODO: make a func for this
                        if isSelected(button: category) {
                            activeCategories.removeAll(where: { $0 == category })
                        } else {
                            activeCategories.append(category)
                        }
                        
                    }) {
                        
                            
                        if isSelected(button: category) {
                            Text(category)
                                .fixedSize()
                            
                                
                        } else {
                            Text(category)
                                .fixedSize()
                                .foregroundColor(.secondary)
                        }
                        }
                    
                    .buttonStyle(.bordered)
                            
                    
               
        }
            }
            
            
                    
            Spacer()
        }.searchable(text: $searchText)
        
        
            
    }
}

struct FilterTesting_Previews: PreviewProvider {
    static var previews: some View {
        let fileManager = MarkdownFileManager()
        fileManager.markdownFiles = MarkdownFile.sampleData
        
        return FilterTesting(fileManager: fileManager)
    }
}
