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
    
    var rating: String { Parser.extractRating(from: recipe.content) }
    
    
    @State private var selection = [String]()
    
    private func selectionChecker(_ string: String) -> Bool {
        if selection.contains(string) {
            return true
        } else {
            return false
        }
    }
    
    private var timesCooked: Int { Parser.extractTimesCooked(from: recipe.content) }
    
    @State private var confettiStopper = false
    
    
    @AppStorage("Servings") var chosenServings = 4

    var body: some View {
        NavigationStack {
            
        
        List {
            Section {
                HStack {
                    Image(systemName: "clock")
                    Text("\(String(Parser.extractTotalTime(from: recipe.content))) min")
                    if rating != "-" {
                        Image(systemName: "star")
                        Text(rating)
                    }
                    Spacer()
                    Image(systemName: "menucard")
                    Text(Parser.extractCategories(from: recipe.content).first!)
                }
                
            }
            Section("Servings") {
                    Stepper("\(chosenServings)", value: $chosenServings, in: 1...1000)
                }
            Section(header: Text("Ingredients")) {
                ForEach(Parser.extractIngredients(from: recipe.content), id: \.self) { ingredient in
                    IngredientView(ingredient: ingredient, recipeServings: Parser.extractServings(from: recipe.content), chosenServings: chosenServings, selected: selectionChecker(ingredient))
                        .monospacedDigit()
                        .onTapGesture {
                            if selectionChecker(ingredient) {
                                selection.removeAll(where: { $0 == ingredient })
                            } else {
                                selection.append(ingredient)
                            }
                            
                        }
                }
            }
            
            Section("Directions") {
                ForEach(Parser.extractDirections(from: recipe.content, withNumbers: true), id: \.self) { direction in
                    VStack(alignment: .leading) {
                        HStack {
                            if selectionChecker(direction) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                            
                            Text(direction).strikethrough(selectionChecker(direction) ? true : false)
                            
                        }
                        
                            .onTapGesture {
                                if selectionChecker(direction) {
                                    selection.removeAll(where: { $0 == direction })
                                } else {
                                    selection.append(direction)
                                }
                                
                            }
                        if Parser.extractTimerInMinutes(from: direction) != 0 {
                            TimerView(timerTime: Parser.extractTimerInMinutes(from: direction))
                        }
                    }
                    
                }
                
            }
            
            Section("Achievements") {
                Button(confettiStopper ? "Well done!" : "I have finished this recipe!") {
                    
                    fileManager.setTimesCooked(of: recipe, to: timesCooked + 1)
                    
                    confettiStopper = true
                }
                .disabled(confettiStopper)
                
                Text(timesCooked == 1 ? "You have cooked this meal 1 time." : "You have cooked this meal \(timesCooked) times.")
                
            }
            
            Section("Notes") {
                Text("Notes come here")
            }
            
            Section("Statistics") {
                Text("Source of the original recipe: ")
                
            }
            
            Text(recipe.content)
                
        }
        .listStyle(.insetGrouped)
        .navigationTitle(recipe.name)
        }
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
     
        RecipeView(fileManager: MarkdownFileManager(), recipe: MarkdownFile.sampleData.last!)
        
        
    }
}
