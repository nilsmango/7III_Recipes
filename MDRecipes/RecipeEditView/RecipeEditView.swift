//
//  RecipeEditView.swift
//  MDRecipes
//
//  Created by Simon Lang on 29.03.23.
//

import SwiftUI

struct RecipeEditView: View {
    @Binding var recipeData: Recipe.Data
    
    @ObservedObject var fileManager: RecipesManager
    
    @State private var newIngredient = ""
    
    var rating: Int {
        Int(String(recipeData.rating.first ?? Character("1"))) ?? 1
    }
    
    // Title validation
    @State private var badTitle = false
    
    private var titles: [String] {
        fileManager.recipes.map { $0.title }
    }
    
    @FocusState private var titleIsFocused: Bool
    
    @State private var oldTitle = "Some title you would never think of"
    
    var body: some View {
        List {
            Section("Name & Co.") {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Title:")
                        TextField("Carrot Cake", text: $recipeData.title)
                        .focused($titleIsFocused)
                        
                        .onChange(of: recipeData.title) { newValue in
                            if titles.contains(recipeData.title) && recipeData.title != oldTitle {
                               badTitle = true
                           } else {
                               badTitle = false
                           }
                       }
                        .onChange(of: titleIsFocused) { newValue in
                            if titles.contains(recipeData.title) && recipeData.title != oldTitle  {
                                recipeData.title += " 2"
                            }
                        }
                       .onSubmit {
                           if titles.contains(recipeData.title) && recipeData.title != oldTitle  {
                               recipeData.title += " 2"
                           }
                        }
                        
                       .onAppear {
                           if recipeData.title != "" {
                               oldTitle = recipeData.title
                           }
                           
                       }
                                            
                            
                        }
                    if badTitle {
                        Text("Title already taken, choose another one or add a number")
                            .font(.caption)
                    }
                    
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
                Section("Select Tags") {
                    TagsEditView(tags: $recipeData.tags, fileManager: fileManager)
                }
                Section("Select Categories") {
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
            Section("Directions") {
                DirectionsEditView(directions: $recipeData.directions)
            }
            
            Section("Nutrition") {
                ZStack {
                    TextEditor(text: $recipeData.nutrition)
                    // this text is to disable the scrolling
                    Text(recipeData.nutrition)
                        .opacity(0)
                        .padding(.vertical, 8)
                }
            }
            
            Section("Notes") {
                ZStack {
                    TextEditor(text: $recipeData.notes)
                    // this text is to disable the scrolling
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
        RecipeEditView(recipeData: .constant(Recipe.sampleData[0].data), fileManager: RecipesManager())
    }
}

