//
//  RecipeView.swift
//  MDRecipes
//
//  Created by Simon Lang on 27.03.23.
//

import SwiftUI

struct RecipeView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var fileManager: RecipesManager
    
    var recipe: Recipe
    
    @AppStorage("Servings") var selectedServings = 4
    
    // confetti
    @State private var confettiStopper = false
    @State private var counter = 0
    private let numberArray = [5, 70, 20]
    
    
    
    // edit view
    @State private var editViewIsPresented = false
    // edit view data
    @State private var data: Recipe.Data = Recipe.Data()
   // image add view
    @State private var addImages = false
    @State private var dataImages = [RecipeImageData]()
    
    var body: some View {
//        NavigationStack {
            ZStack {
                List {
                    Section {
                        HeadSectionView(recipe: recipe, fileManager: fileManager)
                            
                    }
                    
                    Section("Servings") {
                        ServingsView(selectedServings: $selectedServings)
                    }
                    
                    Section("Ingredients") {
                        ForEach(recipe.ingredients) { ingredient in
                            IngredientView(fileManager: fileManager, ingredientString: ingredient.text, recipeServings: recipe.servings, chosenServings: selectedServings, recipe: recipe)
                            
                        }
                    }
                    
                    Section("Directions") {
                        ForEach(recipe.directions) { direction in
                            if let timerManagerIndex = fileManager.timers.firstIndex(where: { $0.recipeTitle == recipe.title && $0.step == direction.step }) {
                                DirectionTimerView(fileManager: fileManager, direction: direction, recipe: recipe, timer: fileManager.timers[timerManagerIndex])
                            } else {
                                DirectionView(fileManager: fileManager, direction: direction, recipe: recipe)
                            }
                        }
                    }
                    
                    Section("Statistics") {
                        Button(confettiStopper ? "Well done!" : "I have finished this recipe!") {
                            fileManager.setTimesCooked(of: recipe, to: recipe.timesCooked + 1)
                            counter += 1
                            confettiStopper = true
                        }
                        .disabled(confettiStopper)
                        
                        Text(recipe.timesCooked == 1 ? "You have cooked this meal 1 time." : "You have cooked this meal \(recipe.timesCooked) times.")
                        HStack {
                            Text("Update Rating:")
                            RecipeRatingEditView(recipe: recipe, fileManager: fileManager)
                                
                        }
                    }
                    
                    if recipe.nutrition != "" {
                        Section("Nutrition") {
                            Text(recipe.nutrition)
                        }
                    }
                    
                    
                    Section("Notes") {
                        NotesView(recipe: recipe, fileManager: fileManager)
                        
                    }
                    
                    
                        Section("Images") {
                            if recipe.images.count > 0 {
                                ForEach(recipe.images) { image in
                                    RecipeImageView(imagePath: image.imagePath, caption: image.caption)
                                }
                            } else {
                                Button {
                                    addImages = true
                                    
                                } label: {
                                    Label("Add Images", systemImage: "camera")
                                }
                                .buttonStyle(.bordered)
                            }
                                
                            
                            
                        }
                    
                    
                    Section("Info") {
                        if recipe.source != "" {
                            Text("Source: \(recipe.source)")
                        }
                        
                        Text("Created: \(recipe.date, style: .date)")
                        
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
                        Button(role: .destructive, action: {
                            if let index = fileManager.recipes.firstIndex(where: { $0.id == recipe.id }) {
                                let indexSet = IndexSet(integer: index)
                                fileManager.delete(at: indexSet)
                                // dismissing the view
                                dismiss()
                            }
                        }, label: {
                            Label("Delete Recipe", systemImage: "trash")
                        })
                    } label: {
                        Label("Edit", systemImage: "ellipsis.circle")
                    }

                    
                }
            }
            .sheet(isPresented: $addImages) {
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
                                Button("Save") {
                                    addImages = false
                                    
                                    var newRecipeData = data
                                    // update recipeData with new images
                                    newRecipeData.dataImages = dataImages
                                    // update recipe
                                    fileManager.updateEditedRecipe(recipe: recipe, data: newRecipeData)
                                }
                            }
                        }
                }
            }
            
            
            .sheet(isPresented: $editViewIsPresented) {
                NavigationView {
                    RecipeEditView(recipeData: $data, fileManager: fileManager)
                        .navigationTitle("Edit Recipe")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Cancel") {
                                    editViewIsPresented = false
                                }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Save") {
                                    editViewIsPresented = false
                                    
                                    fileManager.updateEditedRecipe(recipe: recipe, data: data)
                                }
                            }
                        }
                }
            }
        }
        
        
        
//    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView(fileManager: RecipesManager(), recipe: Parser.makeRecipeFromString(string: MarkdownFile.sampleData.last!.content).recipe)
    }
}
