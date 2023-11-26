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
    
    // custom bindings
    var recipeIndex: Int? {
        guard let index = fileManager.recipes.firstIndex(where: { $0.id == recipe.id }) else {
            fatalError("Can't find the stupid recipe in array")
        }
        return index
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
    
    // for navigating back to home view when we change the category to another category than the open one.
    var categoryFolder: String
    @Environment(\.presentationMode) var presentationMode
    @Binding var recipeMovedAlert: RecipeMovedAlert
    
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
                        IngredientView(fileManager: fileManager, ingredient: bindingIngredient(for: ingredient), recipeServings: recipe.servings, chosenServings: selectedServings, recipe: recipe)
                        
                    }
                }
                
                Section("Directions") {
                    ForEach(recipe.directions) { direction in
                        if let timerManagerIndex = fileManager.timers.firstIndex(where: { $0.recipeTitle == recipe.title && $0.step == direction.step }) {
                            DirectionTimerView(fileManager: fileManager, direction: bindingDirection(for: direction), recipe: recipe, timer: fileManager.timers[timerManagerIndex])
                        } else {
                            DirectionView(fileManager: fileManager, direction: bindingDirection(for: direction), recipe: recipe)
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
                        let newTitle = fileManager.duplicateRecipe(recipe: recipe)
                        data = recipe.data
                        // making sure the edit view has the right title
                        data.title = newTitle
                        editViewIsPresented = true
                        
                    } label: {
                        Label("Duplicate Recipe", systemImage: "doc.badge.plus")
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
                        Button("Save") {
                            
                            addImages = false
                            
                            var newRecipeData = recipe.data
                            
//                            DispatchQueue.main.async {
                            // update recipeData with updated images
                                newRecipeData.dataImages = dataImages
                                // update recipe
                                fileManager.updateEditedRecipe(recipe: recipe, data: newRecipeData)
//                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $editViewIsPresented) {
            NavigationView {
                RecipeEditView(recipeData: $data, fileManager: fileManager, newIngredient: $textFieldIngredient)
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
                                
                                fileManager.updateEditedRecipe(recipe: recipe, data: data)
                                
                                // check if the recipe is still in the category folder
                                if !data.categories.contains(where: { $0 == categoryFolder }) && categoryFolder != "All" && categoryFolder != "" {
                                    // show alert and go back to list
                                    recipeMovedAlert = RecipeMovedAlert(showAlert: true, recipeName: data.title, movedToCategory: data.categories.first!)
                                    self.presentationMode.wrappedValue.dismiss()
                                }                                
                            }
                        }
                    }
            }
        }
    }
    //    }
    
    // not the prettiest way, but way less complicated than making one generic function out of these two.
    private func bindingIngredient(for ingredient: Ingredient) -> Binding<Ingredient> {
        
        // find the ingredient
        guard let ingredientIndex = fileManager.recipes[recipeIndex!].ingredients.firstIndex(where: { $0.id == ingredient.id }) else {
//            fatalError("Can't find the stupid ingredient in array")
            // a little hack: make fake binding when the model is slower than the ui
            return Binding(get: { Ingredient(text: "Wow") }, set: { _ in })
        }
        return $fileManager.recipes[recipeIndex!].ingredients[ingredientIndex]
    }
    
    private func bindingDirection(for direction: Direction) -> Binding<Direction> {
        
        // find the direction
        guard let directionIndex = fileManager.recipes[recipeIndex!].directions.firstIndex(where: { $0.id == direction.id }) else {
//            fatalError("Can't find the stupid direction in array")
            // a little hack: make fake binding when the model is slower than the ui
            return Binding(get: { Direction(step: 200, text: "nope", hasTimer: false, timerInMinutes: 0.0) }, set: { _ in })
        }
        return $fileManager.recipes[recipeIndex!].directions[directionIndex]
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView(fileManager: RecipesManager(), recipe: Parser.makeRecipeFromString(string: MarkdownFile.sampleData.last!.content).recipe, categoryFolder: "No Category", recipeMovedAlert: .constant(RecipeMovedAlert(showAlert: false, recipeName: "", movedToCategory: "")))
    }
}
