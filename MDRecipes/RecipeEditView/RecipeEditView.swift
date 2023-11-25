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
    
    @Binding var newIngredient: String
    
    var comingFromImportView: Bool = false
    
    var rating: Int {
        Int(String(recipeData.rating.first ?? Character("0"))) ?? 0
    }
    
    
    var body: some View {
        //        ScrollView {
        //            VStack {
        
        List {
            Section("Name & Co.") {
                TitleEditView(title: $recipeData.title, titles: fileManager.getTitles(), comingFromImportView: comingFromImportView)
                
                LanguagePickerView(language: $recipeData.language)
                
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
                    TextField("20 Minutes", text: $recipeData.prepTime)
                }
                
                HStack {
                    Text("Cook time:")
                    TextField("1 h", text: $recipeData.cookTime)
                }
                
                HStack {
                    Text("Additional time:")
                    TextField("1 h 20 min", text: $recipeData.additionalTime)
                }
                
                HStack {
                    Text("Total time:")
                    TextField("140 min", text: $recipeData.totalTime)
                }
            }
            
            Section("Misc") {
                ServingsCookedEditView(servings: $recipeData.servings, timesCooked: $recipeData.timesCooked)
                
                DatePicker("Creation date:", selection: $recipeData.date, displayedComponents: .date)
            }
            
            Section("Ingredients") {
                IngredientsEditView(ingredients: $recipeData.ingredients, newIngredient: $newIngredient)
            }
            
            Section("Directions") {
                DirectionsEditView(directions: $recipeData.directions)
            }
            
            Group {
                Section("Nutrition") {
                    ZStack(alignment: .leading) {
                        TextEditor(text: $recipeData.nutrition)
                        // this text is to disable the scrolling
                        Text(recipeData.nutrition)
                            .opacity(0)
                            .padding(.vertical, 8)
                    }
                }
                
                Section("Notes") {
                    ZStack(alignment: .leading) {
                        TextEditor(text: $recipeData.notes)
                        // this text is to disable the scrolling
                        Text(recipeData.notes)
                            .opacity(0)
                            .padding(.vertical, 8)
                    }
                    
                }
                
                ImagesPickerView(dataImages: $recipeData.dataImages)
            }
        }
        .listStyle(.insetGrouped)
    }
}

//    }
//
//}

struct RecipeEditView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeEditView(recipeData: .constant(Recipe.sampleData[0].data), fileManager: RecipesManager(), newIngredient: .constant(""))
    }
}

