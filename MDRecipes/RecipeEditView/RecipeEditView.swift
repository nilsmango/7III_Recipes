//
//  RecipeEditView.swift
//  MDRecipes
//
//  Created by Simon Lang on 29.03.23.
//

import SwiftUI

struct RecipeEditView: View {
    @Binding var recipeData: Recipe.Data
    
    @ObservedObject var fileManager: MarkdownFileManager
    
    @State private var newIngredient = ""
    
    var rating: Int {
        Int(String(recipeData.rating.first ?? Character("1"))) ?? 1
    }
    
    var body: some View {
        List {
            Section("Name & Co.") {
                
                    HStack {
                        Text("Title:")
                        TextField("Carrot Cake", text: $recipeData.title)
                    }
                    HStack {
                        Text("Source:")
                        TextField("Source of the Recipe", text: $recipeData.source)
                    }
                HStack {
                    Text("Rating:")
                    ForEach(1...5, id: \.self) { selectedRating in
                        let fill = rating >= selectedRating
                        Image(systemName: fill ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .onTapGesture {
                                recipeData.rating = "\(selectedRating)/5"
                            }
                    }
                
                }
                }
                Section("Tags") {
                    TagsEditView(tags: $recipeData.tags, fileManager: fileManager)
                }
                Section("Categories") {
                    CategoriesEditView(categories: $recipeData.categories, fileManager: fileManager)
                }
                Section("Time") {
                    
                   
                    HStack {
                        Text("Prep time:")
                        TextField("Time Unit", text: $recipeData.prepTime)
                    }
                    
                    HStack {
                        Text("Cook time:")
                        TextField("Time Unit", text: $recipeData.cookTime)
                    }
                    
                    HStack {
                        Text("Additional time:")
                        TextField("Time Unit", text: $recipeData.additionalTime)
                    }
                    
                    HStack {
                        Text("Total time:")
                        TextField("Time Unit", text: $recipeData.totalTime)
                    }
                }
                
                Section("Misc") {
                    ServingsCookedEditView(servings: $recipeData.servings, timesCooked: $recipeData.timesCooked)
                    
                    DatePicker("Creation date:", selection: $recipeData.date, displayedComponents: .date)
                    
                    LanguagePickerView(language: $recipeData.language)
                }
                
             
                        
            Section("Ingredients") {
                IngredientsEditView(ingredients: $recipeData.ingredients)
            }
            Section(header: Text("Directions")) {
                DirectionsEditView(directions: $recipeData.directions)
            }
            Section("Notes") {
                ZStack {
                    TextEditor(text: $recipeData.notes)
                    Text(recipeData.notes)
                        .opacity(0)
                        .padding(.vertical, 8)
                }
            }
            
          
                Section("Images") {
                    // TODO: image picker
                    Text(recipeData.images)
                }
            
        }
        .listStyle(.insetGrouped)
    }
    

    
}

struct RecipeEditView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeEditView(recipeData: .constant(Recipe.sampleData[0].data), fileManager: MarkdownFileManager())
    }
}

