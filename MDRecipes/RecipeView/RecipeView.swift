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
    
    // notes
    @State private var note = ""
    @State private var saveNotes = false
    
    // rating
    @State private var rating = 1
    
    // edit view
    @State private var editViewIsPresented = false
    // edit view data
    @State private var data: Recipe.Data = Recipe.Data()
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section {
                        HeadSectionView(recipe: recipe, fileManager: fileManager, rating: $rating)
                            .onAppear {
                                
                                // loading the rating
                                rating = Int(String(recipe.rating.first ?? Character("1"))) ?? 1
                                // loading the notes
                                note = recipe.notes
                            }
                            .onDisappear {
                                
                                if saveNotes {
                                    fileManager.updateNoteSection(of: recipe, to: note)
                                }
                            }
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
                                DirectionTimerView(fileManager: fileManager, direction: direction, recipe: recipe, timer: $fileManager.timers[timerManagerIndex])
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
                            RecipeRatingView(rating: $rating, recipe: recipe, fileManager: fileManager)
                                
                        }
                    }
                    
                    if recipe.nutrition != "" {
                        Section("Nutrition") {
                            Text(recipe.nutrition)
                        }
                    }
                    
                    
                    Section("Notes") {
                        ZStack(alignment: .leading) {
                            TextEditor(text: $note)
                            Text(note)
                                .opacity(0)
                                .padding(.vertical, 8)
                        }
                        
                    }
                    
                    .onChange(of: note) { _ in
                        saveNotes = true
                    }
                    
                    
                    if recipe.images.count > 0 {
                        Section("Images") {
                            ForEach(recipe.images) { image in
                                RecipeImageView(imagePath: image.imagePath, caption: image.caption)
                            }
                        }
                    }
                    
                    Section("Info") {
                        Text("Source: \(recipe.source)")
                        Text("Created: \(recipe.date, style: .date)")
                        
                        FlexiStringsView(strings: recipe.tags)
                        
                        FlexiStringsView(strings: recipe.categories)
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
                                    
                                    data = Recipe.Data()
                                }
                            }
                        }
                }
            }
        }
        
        
        
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView(fileManager: RecipesManager(), recipe: Parser.makeRecipeFromString(string: MarkdownFile.sampleData.last!.content).recipe)
    }
}
