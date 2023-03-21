//
//  RecipeView.swift
//  MDRecipes
//
//  Created by Simon Lang on 17.03.23.
//

import SwiftUI

struct RecipeView: View {
    @ObservedObject var fileManager: MarkdownFileManager
    
    var recipe: MarkdownFile
    
    var rating: String { fileManager.extractRating(from: recipe.content) }
    
    private func selectionChecker(_ string: String) -> Bool {
        if ingredientSelection.contains(string) {
            return true
        } else {
            return false
        }
    }
    
    @State private var ingredientSelection = [String]()
    
    @AppStorage("Servings") var chosenServings = 4

    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "clock")
                    Text("\(String(fileManager.extractTotalTime(from: recipe.content))) min")
                    if rating != "-" {
                        Image(systemName: "star")
                        Text(rating)
                    }
                    Spacer()
                    Image(systemName: "menucard")
                    Text(fileManager.extractCategories(from: recipe.content).first!)
                }
                
            }
            Section("Servings") {
                    Stepper("\(chosenServings)", value: $chosenServings, in: 1...1000)
                }
            Section(header: Text("Ingredients")) {
                ForEach(fileManager.extractIngredients(from: recipe.content), id: \.self) { ingredient in
                    IngredientView(ingredient: ingredient, recipeServings: fileManager.extractServings(from: recipe.content), chosenServings: chosenServings, selected: selectionChecker(ingredient))
                        .monospacedDigit()
                        .onTapGesture {
                            if selectionChecker(ingredient) {
                                ingredientSelection.removeAll(where: { $0 == ingredient })
                            } else {
                                ingredientSelection.append(ingredient)
                            }
                            
                        }
                }
            }
            
            Section("Directions") {
                ForEach(fileManager.extractDirections(from: recipe.content, withNumbers: true), id: \.self) { direction in
                    Text(direction)
                }
            }
            
            Section("Notes") {
                Text("Notes come here")
            }
            
            Section("Statistics") {
                Text("You have cooked this 50 times.")
                Text("Source of the original recipe: ")
                
            }
            
            Text(recipe.content)
        }
        .onAppear() {
//            chosenServings = fileManager.extractServings(from: recipe.content)
        }
        .navigationTitle(recipe.name)
        
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RecipeView(fileManager: MarkdownFileManager(), recipe: MarkdownFile.sampleData.last!)
        }
        
    }
}
