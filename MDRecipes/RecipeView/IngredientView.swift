//
//  IngredientView.swift
//  MDRecipes
//
//  Created by Simon Lang on 21.03.23.
//

import SwiftUI

struct IngredientView: View {
    @ObservedObject var fileManager: RecipesManager
    
    @Binding var ingredient: Ingredient

    var recipeServings: Int
    var chosenServings: Int
    
    // Edit View
    @State private var showIngredientsEdit = false
    var recipe: Recipe
    @State private var ingredients = [Ingredient]()
    @State private var textFieldIngredient = ""
    
    var body: some View {
        HStack {
            
            Image(systemName: ingredient.selected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(ingredient.selected ? .blue : .primary)
            
            Text(Parser.stringMaker(of: ingredient.text.trimmingCharacters(in: .whitespaces), selectedServings: chosenServings, recipeServings: recipeServings))
        }
        .onTapGesture {
//            selected.toggle()
            ingredient.selected.toggle()
        }
        .onLongPressGesture {
            ingredients = recipe.ingredients
            showIngredientsEdit = true
        }
        
        .sheet(isPresented: $showIngredientsEdit) {
            NavigationView {
                QuickIngredientsEditView(ingredients: $ingredients, textFieldIngredient: $textFieldIngredient, servings: recipeServings)
                    .navigationTitle("Edit Ingredients")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showIngredientsEdit = false
                                textFieldIngredient = ""
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Update") {
                                showIngredientsEdit = false
                                
                                if textFieldIngredient.trimmingCharacters(in: .whitespaces) != "" {
                                    ingredients.append(Ingredient(text: textFieldIngredient))
                                    textFieldIngredient = ""
                                }
                                // update the ingredients of this recipe
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
        IngredientView(fileManager: RecipesManager(), ingredient: .constant(Ingredient(text: "Banana", id: UUID())), recipeServings: 4, chosenServings: 6, recipe: Recipe.sampleData[0])
    }
}
