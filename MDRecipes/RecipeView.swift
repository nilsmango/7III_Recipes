//
//  RecipeView.swift
//  MDRecipes
//
//  Created by Simon Lang on 27.03.23.
//

import SwiftUI

struct RecipeView: View {
    var recipe: Recipe
    
    @AppStorage("Servings") var selectedServings = 4

    // ingredient selection
    @State private var selectedIngredientsSet = Set<String>()
    private func selectedIngredient(ingredientName: String) -> Bool {
        if selectedIngredientsSet.contains(ingredientName) {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section {
                        HStack {
                            Image(systemName: "clock")
                            Text("\(recipe.totalTime)")
                            if recipe.rating != "" {
                                Image(systemName: "star")
                                Text(recipe.rating)
                            }
                            Spacer()
                            Image(systemName: "menucard")
                            Text(recipe.categories.first!)
                        }
                        
                    }
                    
                    Section("Servings") {
                        Stepper("\(selectedServings)", value: $selectedServings, in: 1...1000)
                    }
                    
                    Section("Ingredients") {
                        ForEach(recipe.ingredients) { ingredient in
                            
                            IngredientView(ingredientString: ingredient.name, recipeServings: recipe.servings, chosenServings: selectedServings, selected: selectedIngredient(ingredientName: ingredient.name))
                                // mark ingredient as checked.
                                .onTapGesture {
                                    if selectedIngredient(ingredientName: ingredient.name) {
                                        selectedIngredientsSet.remove(ingredient.name)
                                    } else {
                                        selectedIngredientsSet.insert(ingredient.name)
                                    }
                                }
                        }
                    }
                                    
                    Section("Directions") {
                        ForEach(recipe.directions) { direction in
                            DirectionView(direction: direction)
                            
                        }
                    }
                    
                    
                    
                }
            }
            .navigationTitle(recipe.title)
        }
        
        
        
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView(recipe: Parser.makeRecipeFromMarkdown(markdown: MarkdownFile.sampleData.last!))
    }
}
