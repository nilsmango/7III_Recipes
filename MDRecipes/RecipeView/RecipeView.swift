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
    @State private var counter = 0
    private let numberArray = [5, 70, 20]
    
    // notes
    @State private var note = ""
    @State private var saveNotes = false
    
    @State private var rating = 1
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section {
                        HeadSectionView(recipe: recipe, fileManager: fileManager, rating: $rating)
                            .onAppear {
                                rating = Int(String(recipe.rating.first ?? Character("1"))) ?? 1
                            }
                    }
                    
                    Section("Servings") {
                        HStack {
                            Text("\(selectedServings)")
                            Spacer()
                            Button(action: {
                                if selectedServings > 1 {
                                    selectedServings -= 1
                                }
                                
                            }) {
                                Image(systemName: "minus.circle")
                            }
                            .buttonStyle(.bordered)
                            Button(action: {
                                selectedServings += 1
                            }) {
                                Image(systemName: "plus.circle")
                            }
                            .buttonStyle(.bordered)
                        }
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
                        ZStack {
                            TextEditor(text: $note)
                            Text(note).opacity(0).padding(.all, 8)
                        }
                        
                    }
                    .onAppear {
                        note = recipe.notes
                    }
                    .onChange(of: note) { _ in
                        saveNotes = true
                    }
                    .onDisappear {
                        if saveNotes {
                            fileManager.updateNoteSection(of: recipe, to: note)
                        }
                    }
                    
                    if recipe.images != "" {
                        Section("Images") {
                            Text(recipe.images)
                        }
                    }
                    
                    Section("Info") {
                        Text("Source: \(recipe.source)")
                        Text("Created: \(recipe.date, style: .date)")
                        Text("Add tags and categories Views here, with navigationlinks to tap them")
                        
                    }
                    
                }
                .listStyle(.insetGrouped)
                
                // ZStack Layer
                ConfettiCannon(counter: $counter, num: numberArray, colors: [.blue, .red, .yellow, .purple, .green, .black])
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
