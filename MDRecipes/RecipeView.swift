//
//  RecipeView.swift
//  MDRecipes
//
//  Created by Simon Lang on 27.03.23.
//

import SwiftUI

struct RecipeView: View {
    @ObservedObject var fileManager: MarkdownFileManager
    
//    @StateObject private var timerManager = TimerManager()
    
    
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
    
    // confetti
    @State private var confettiStopper = false
    
    
    
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
                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            
                            IngredientView(ingredientString: ingredient, recipeServings: recipe.servings, chosenServings: selectedServings, selected: selectedIngredient(ingredientName: ingredient))
                                // mark ingredient as checked.
                                .onTapGesture {
                                    if selectedIngredient(ingredientName: ingredient) {
                                        selectedIngredientsSet.remove(ingredient)
                                    } else {
                                        selectedIngredientsSet.insert(ingredient)
                                    }
                                }
                        }
                    }
                                    
                    Section("Directions") {
                        ForEach(recipe.directions) { direction in
                            DirectionView(direction: direction)
                        }
                    }
                    
                    Section("Achievements") {
                        Button(confettiStopper ? "Well done!" : "I have finished this recipe!") {
                            // TODO: wenn recipe binding hier einfach grad ändern saving!!
//                            fileManager.setTimesCooked(of: Parser.makeMarkdownFromRecipe(recipe: recipe), to: recipe.timesCooked + 1)
                            
                            confettiStopper = true
                        }
                        .disabled(confettiStopper)
                        
                        Text(recipe.timesCooked == 1 ? "You have cooked this meal 1 time." : "You have cooked this meal \(recipe.timesCooked) times.")
                        
                    }
                    
                    if recipe.nutrition != "" {
                        Section("Nutrition") {
                            Text(recipe.nutrition)
                        }
                    }
                    
                    
                    Section("Notes") {
                        // TODO: 1. wenn recipe binding hat dann einfach textfield mit binding hier
                        
                            Text(recipe.notes)
                        
                    }
                    
                    if recipe.images != "" {
                        Section("Images") {
                            Text(recipe.images)
                        }
                    }
                    
                    Section("Source") {
                        Text(recipe.source)
                    }
                    
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle(recipe.title)
        }
        
        
        
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView(fileManager: MarkdownFileManager(), recipe: Parser.makeRecipeFromMarkdown(markdown: MarkdownFile.sampleData.last!))
    }
}
