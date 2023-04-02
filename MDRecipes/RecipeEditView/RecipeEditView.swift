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
    
    // all titles of all the recipes
    private var titles: [String] {
        fileManager.recipes.map { $0.title }
    }
    
    // checking if title and also sanitized title is not in all titles and if title is not the oldTitle if we are editing the recipe
    private var invalidTitle: Bool {
        ( titles.contains(recipeData.title) || titles.contains(Parser.sanitizeFileName(recipeData.title)) ) && recipeData.title != oldTitle
    }
    
    @FocusState private var titleIsFocused: Bool
    
    @State private var oldTitle = "Some title you would never think of"
    
    private func createUniqueTitle() {
        if invalidTitle  {
            // save the committed title so we can reuse it for version numbering
            let chosenTitle = recipeData.title
            for versionNumber in (2...20) {
                // adding a funny version number to the committed title
                recipeData.title = chosenTitle + " No. \(versionNumber)"
                if !invalidTitle {
                    return
                }
            }
        }
    }
    
    var body: some View {
        List {
            Section("Name & Co.") {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Title:")
                        TextField("Carrot Cake", text: $recipeData.title)
                        .focused($titleIsFocused)
                        
                        .onChange(of: recipeData.title) { newValue in
                            if invalidTitle {
                               badTitle = true
                           } else {
                               badTitle = false
                           }
                       }
                        .onChange(of: titleIsFocused) { newValue in
                            createUniqueTitle()
                        }
                       .onSubmit {
                           createUniqueTitle()
                        }
                        
                       .onAppear {
                           if recipeData.title != "" {
                               oldTitle = recipeData.title
                           }
                           
                       }
                                            
                            
                        }
                    if badTitle {
                        Text("Title already taken, choose another one or I will.")
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

