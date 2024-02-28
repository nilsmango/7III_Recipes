//
//  RecipeView.swift
//  MDRecipes
//
//  Created by Simon Lang on 27.03.23.
//

import SwiftUI

struct RecipeView: View {
    
    @ObservedObject var recipesManager: RecipesManager
    
    var recipe: Recipe
    
    @AppStorage("Servings") var selectedServings = 4
    
    // custom bindings
    var recipeIndex: Int? {
        if let index = recipesManager.recipes.firstIndex(where: { $0.id == recipe.id }) {
            return index
        } else {
            return nil
        }
    }
    
    // confetti
    @State private var confettiStopper = false
    @State private var counter = 0
    private let numberArray = [5, 70, 20]
    
    // edit view
    @State private var editViewIsPresented = false
    @State private var textFieldIngredient = ""
    // edit view data
    @State private var data: Recipe.Data = Recipe.Data()
    // image add view
    @State private var addImages = false
    @State private var dataImages = [RecipeImageData]()
    
    var body: some View {
        // small hack to get correct updating in swiftui
        let recipe = recipesManager.recipes.first(where: { $0.id == self.recipe.id }) ?? Recipe.sampleData.first!
        ZStack {
            List {
                Section {
                    HeadSectionView(recipe: recipe, fileManager: recipesManager)
                    
                }
                
                Section("Servings") {
                    ServingsView(selectedServings: $selectedServings)
                }
                
                Section("Ingredients") {
                    ForEach(recipe.ingredients) { ingredient in
                        IngredientView(fileManager: recipesManager, ingredient: bindingIngredient(for: ingredient), recipeServings: recipe.servings, chosenServings: selectedServings, recipe: recipe)
                        
                    }
                }
                
                Section("Directions") {
                    ForEach(recipe.directions) { direction in
                        if let timerManagerIndex = recipesManager.timers.firstIndex(where: { $0.recipeTitle == recipe.title && $0.step == direction.step }) {
                            DirectionTimerView(fileManager: recipesManager, direction: bindingDirection(for: direction), recipe: recipe, timer: recipesManager.timers[timerManagerIndex])
                        } else {
                            DirectionView(fileManager: recipesManager, direction: bindingDirection(for: direction), recipe: recipe)
                        }
                    }
                }
                
                Section("Statistics") {
                    Button(confettiStopper ? "Well done!" : "I have finished this recipe!") {
                        recipesManager.setTimesCooked(of: recipe, to: recipe.timesCooked + 1)
                        counter += 1
                        confettiStopper = true
                    }
                    .disabled(confettiStopper)
                    
                    Text(recipe.timesCooked == 1 ? "You have cooked this meal 1 time." : "You have cooked this meal \(recipe.timesCooked) times.")
                    HStack {
                        Text("Update Rating:")
                        RecipeRatingEditView(recipe: recipe, fileManager: recipesManager)
                        
                    }
                }
                
                if recipe.nutrition != "" {
                    Section("Nutrition") {
                        Text(recipe.nutrition)
                    }
                }
                
                Section("Notes") {
                    NotesView(recipe: recipe, fileManager: recipesManager)
                }
                
                Section("Images") {
                    if recipe.images.count > 0 {
                        ForEach(recipe.images) { image in
                            RecipeImageView(imagePath: image.imagePath, caption: image.caption)
                        }
                    }
                    Button {
                        // updating data images with all the images in the recipe
                        dataImages = recipe.data.dataImages
                        addImages = true
                        
                    } label: {
                        Label(recipe.images.count > 0 ? "Edit Images" : "Add Images", systemImage: "camera")
                    }
                    .buttonStyle(.bordered)
                }
                
                Section("Info") {
                    if recipe.source != "" {
                        Text("Source: \(recipe.source)")
                    }
                    
                    Text("Created: \(recipe.date, style: .date)")
                    Text("Last update: \(recipe.updated, style: .date)")
                    if recipe.tags.count > 0 {
                        FlexiStringsView(strings: recipe.tags)
                    }
                    if recipe.categories.count > 0 {
                        FlexiStringsView(strings: recipe.categories)
                    }
                }
            }
            .listStyle(.insetGrouped)
            
            // ZStack Layer
            ConfettiCannon(counter: $counter, num: numberArray, colors: [.blue, .red, .yellow, .purple, .green, .black])
        }
        .scrollContentBackground(.hidden)
        .background(
            .gray
                .opacity(0.1)
        )
        .navigationTitle(recipe.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        editViewIsPresented = true
                        data = recipe.data
                    } label: {
                        Label("Edit Recipe", systemImage: "square.and.pencil")
                    }
                    
                    Button {
                        let newTitle = recipesManager.duplicateRecipe(recipe: recipe)
                        
                        data = recipe.data
                        
                        // making sure the edit view has the right title
                        data.title = newTitle
                        
                        // reseting the times cooked
                        data.timesCooked = 0
                        
                        // removing the images for the new recipe
                        data.oldImages = []
                        data.dataImages = []
                        
                        editViewIsPresented = true
                        
                    } label: {
                        Label("Duplicate Recipe", systemImage: "doc.badge.plus")
                    }
                    
                    Button(role: .destructive, action: {
                        if let index = recipesManager.recipes.firstIndex(where: { $0.id == recipe.id }) {
                            let indexSet = IndexSet(integer: index)
                            // dismissing the view
                            recipesManager.dismissView()
                            recipesManager.delete(at: indexSet)
                            
                        }
                    }, label: {
                        Label("Delete Recipe", systemImage: "trash")
                    })
                    
                } label: {
                    Label("Edit", systemImage: "ellipsis.circle")
                }
            }
        }
        .fullScreenCover(isPresented: $addImages) {
            NavigationView {
                List {
                    ImagesPickerView(dataImages: $dataImages)
                }
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            addImages = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Update") {
                            
                            addImages = false
                            
                            var newRecipeData = recipe.data
                            
//                            DispatchQueue.main.async {
                            // update recipeData with updated images
                                newRecipeData.dataImages = dataImages
                                // update recipe
                                recipesManager.updateEditedRecipe(recipe: recipe, data: newRecipeData)
//                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $editViewIsPresented) {
            NavigationView {
                RecipeEditView(recipeData: $data, fileManager: recipesManager, newIngredient: $textFieldIngredient)
                    .navigationTitle("Edit Recipe")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                editViewIsPresented = false
                                textFieldIngredient = ""
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                
                                editViewIsPresented = false
                                
                                if textFieldIngredient.trimmingCharacters(in: .whitespaces) != "" {
                                    data.ingredients.append(Ingredient(text: textFieldIngredient))
                                    textFieldIngredient = ""
                                }
                                
                                recipesManager.updateEditedRecipe(recipe: recipe, data: data)
                                
                                                              
                            }
                        }
                    }
            }
        }
    }
    
    // not the prettiest way, but way less complicated than making one generic function out of these two.
    private func bindingIngredient(for ingredient: Ingredient) -> Binding<Ingredient> {
        
        // if no recipe then return fake binding
        if recipeIndex == nil {
            return Binding(get: { Ingredient(text: "Wow") }, set: { _ in })
        } else {
            // find the ingredient
            guard let ingredientIndex = recipesManager.recipes[recipeIndex!].ingredients.firstIndex(where: { $0.id == ingredient.id }) else {
                // a little hack: make fake binding when the model is slower than the ui
                return Binding(get: { Ingredient(text: "Wow") }, set: { _ in })
            }
            return $recipesManager.recipes[recipeIndex!].ingredients[ingredientIndex]
        }
    }
    
    private func bindingDirection(for direction: Direction) -> Binding<Direction> {
        
        // if no recipe then return fake binding
        if recipeIndex == nil {
            return Binding(get: { Direction(step: 200, text: "nope", hasTimer: false, timerInMinutes: 0.0) }, set: { _ in })
        } else {
            // find the direction
            guard let directionIndex = recipesManager.recipes[recipeIndex!].directions.firstIndex(where: { $0.id == direction.id }) else {
                // a little hack: make fake binding when the model is slower than the ui
                return Binding(get: { Direction(step: 200, text: "nope", hasTimer: false, timerInMinutes: 0.0) }, set: { _ in })
            }
            return $recipesManager.recipes[recipeIndex!].directions[directionIndex]
        }
    }
}

#Preview {
        RecipeView(recipesManager: RecipesManager(), recipe: Parser.makeRecipeFromString(string: MarkdownFile.sampleData.last!.content).recipe)
}
