//
//  IngredientView.swift
//  MDRecipes
//
//  Created by Simon Lang on 21.03.23.
//

import SwiftUI

struct IngredientView: View {
    @ObservedObject var fileManager: RecipesManager
    
    var ingredientString: String
    var recipeServings: Int
    var chosenServings: Int
    @State private var selected = false
    
    // Edit View
    @State private var showIngredientsEdit = false
    var recipe: Recipe
    @State private var ingredients = [Ingredient]()
    
    var body: some View {
        HStack {
            
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(selected ? .blue : .primary)
            
            Text(Parser.stringMaker(of: ingredientString, selectedServings: chosenServings, recipeServings: recipeServings))
        }
        .onTapGesture {
            selected.toggle()
        }
        .onLongPressGesture {
            ingredients = recipe.ingredients
            showIngredientsEdit = true
        }
        
        .sheet(isPresented: $showIngredientsEdit) {
            NavigationView {
                QuickIngredientsEditView(ingredients: $ingredients, servings: recipeServings)
                    .navigationTitle("Edit Ingredients")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showIngredientsEdit = false
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Update") {
                                showIngredientsEdit = false
                                
                                // update the ingredients of this recipe
//                                fileManager.updatingDirectionsOfRecipe(directionsString: directionsString, of: recipe)
                                fileManager.updatingIngredientsOfRecipe(ingredients: ingredients, of: recipe)
                                
                                
                            }
                        }
                    }
            }
        }
        
    }
    
}

struct IngredientView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientView(fileManager: RecipesManager(), ingredientString: "1 egg", recipeServings: 4, chosenServings: 6, recipe: Recipe.sampleData[0])
    }
}
