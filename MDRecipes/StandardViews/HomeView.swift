//
//  HomeView.swift
//  MDRecipes
//
//  Created by Simon Lang on 20.03.23.
//

import SwiftUI

struct HomeView: View {    
    @ObservedObject var fileManager: RecipesManager
    
    @State var searchText = ""
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    private var randomRecipe: Recipe? { fileManager.randomRecipe() }
    
    // Edit Things
    @State private var editViewPresented = false
    
    @State private var newIngredient = ""
    
    @State private var importViewPresented = false
    
    @State private var newRecipeData = Recipe.Data()
    
    @State private var importSaveDisabled = true
    
    @State private var showNewRecipeButtons = false
    
    var body: some View {
        NavigationStack {
            if searchText.isEmpty {
                ScrollView {
                    
                    VStack(alignment: .leading) {
                        let allRecipes = fileManager.filterTheRecipes(string: "", ingredients: [], categories: [], tags: []).count
                        
                        if allRecipes > 0 {
                            Text("7III Recipes")
                                .font(.title3)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                                .padding([.horizontal, .top])
                            LazyVGrid(columns: columns) {
                                NavigationLink(destination: RecipesListView(fileManager: fileManager, category: "")) {
                                    FolderView(categoryFolder: "All", categoryNumber: String(allRecipes))
                                }
                                
                                ForEach(fileManager.getAllCategories(), id: \.self) { category in
                                    NavigationLink(destination: RecipesListView(fileManager: fileManager, category: category)) {
                                        FolderView(categoryFolder: category, categoryNumber: String(fileManager.filterTheRecipes(string: "", ingredients: [], categories: [category], tags: []).count))
                                        
                                    }
                                    
                                }
                                if randomRecipe != nil {
                                    NavigationLink(destination: RecipeView(fileManager: fileManager, recipe: randomRecipe!, categoryFolder: "All", recipeMovedAlert: .constant(RecipeMovedAlert(showAlert: false, recipeName: "", movedToCategory: "")))) {
                                        RandomRecipeView()
                                        
                                    }
                                }
                                
                            }
                            
                            .padding([.horizontal])
                            
                            let allTags = fileManager.getAllTags()
                            if allTags.count > 0 {
                                Text("Tags")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                                    .padding([.horizontal, .top])
                                
                                FlexiTagsView(fileManager: fileManager, strings: allTags)
                                    .padding(.horizontal)
                            }
                            
                        }
                        HStack {
                            Spacer()
                            
                            if showNewRecipeButtons {
                                Button(action: {
                                    editViewPresented = true
                                    showNewRecipeButtons = false
                                }) {
                                    Label("Write New", systemImage: "square.and.pencil")
                                        .fontWeight(.bold)
                                        .fontDesign(.rounded)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .foregroundColor(Color("FolderBG"))
                                        )
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    importViewPresented = true
                                    showNewRecipeButtons = false
                                }) {
                                    Label("From Text", systemImage: "square.and.arrow.down")
                                        .fontWeight(.bold)
                                        .fontDesign(.rounded)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .foregroundColor(Color("FolderBG"))
                                        )
                                }
                            } else {
                                Button(action: {
                                    showNewRecipeButtons = true
                                }) {
                                    Label("Add new Recipe", systemImage: "plus.circle.fill")
                                        .fontWeight(.bold)
                                        .fontDesign(.rounded)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .foregroundColor(Color("FolderBG"))
                                        )
                                }
                                
                            }
                            
                            Spacer()
                        }
                        .padding()
                        
                    }
                }
                
                .background(
                    .gray
                        .opacity(0.1)
                )
                //                .navigationTitle("Categories")
                .toolbar {
                    
                    ToolbarOptionsView(fileManager: fileManager, editViewPresented: $editViewPresented, importViewPresented: $importViewPresented, sortingSelection: .constant(.standard), isHomeView: true)
                }
                
            } else {
                List {
                    ForEach(fileManager.getAllCategories(), id: \.self) { category in
                        if !fileManager.filterTheRecipes(string: searchText, ingredients: [], categories: [category], tags: []).isEmpty {
                            Section {
                                ForEach(fileManager.filterTheRecipes(string: searchText, ingredients: [], categories: [category], tags: [])) { recipe in
                                    NavigationLink(destination: RecipeView(fileManager: fileManager, recipe: recipe, categoryFolder: category, recipeMovedAlert: .constant(RecipeMovedAlert(showAlert: false, recipeName: "", movedToCategory: "")))) {
                                        ListItemView(recipe: recipe)
                                    }
                                }
                            } header: {
                                Text(category)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                            }
                        }
                        
                        
                    }
                    
                }
                
            }
            
            
        }
        .scrollContentBackground(.hidden)
        .searchable(text: $searchText)
        .background(ignoresSafeAreaEdges: .all)
        // making the font rounded
        .customNavBar()
        
        .fullScreenCover(isPresented: $editViewPresented, content: {
            NavigationView {
                RecipeEditView(recipeData: $newRecipeData, fileManager: fileManager, newIngredient: $newIngredient)
                    .navigationTitle(newRecipeData.title == "" ? "New Recipe" : newRecipeData.title)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                editViewPresented = false
                                
                                newIngredient = ""
                                // reseting newRecipeData
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    newRecipeData.timesCooked = 0
                                    newRecipeData.title = ""
                                    newRecipeData.source = ""
                                    newRecipeData.tags = []
                                    newRecipeData.categories = []
                                    newRecipeData.prepTime = ""
                                    newRecipeData.cookTime = ""
                                    newRecipeData.additionalTime = ""
                                    newRecipeData.totalTime = ""
                                    newRecipeData.notes = ""
                                    newRecipeData.nutrition = ""
                                    newRecipeData.directions = []
                                    newRecipeData.servings = 4
                                    newRecipeData.ingredients = []
                                    newRecipeData.dataImages = []
                                    newRecipeData.date = Date.now
                                }
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                editViewPresented = false
                                
                                addNotSubmittedIngredient()
                                
                                // saving the new recipe
                                fileManager.saveNewRecipe(newRecipeData: newRecipeData)
                                
                                // reseting newRecipeData
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    newRecipeData.timesCooked = 0
                                    newRecipeData.title = ""
                                    newRecipeData.source = ""
                                    newRecipeData.tags = []
                                    newRecipeData.categories = []
                                    newRecipeData.prepTime = ""
                                    newRecipeData.cookTime = ""
                                    newRecipeData.additionalTime = ""
                                    newRecipeData.totalTime = ""
                                    newRecipeData.notes = ""
                                    newRecipeData.nutrition = ""
                                    newRecipeData.directions = []
                                    newRecipeData.servings = 4
                                    newRecipeData.ingredients = []
                                    newRecipeData.dataImages = []
                                    newRecipeData.date = Date.now
                                    
                                }
                                
                            }
                        }
                    }
            }
        })
        .fullScreenCover(isPresented: $importViewPresented, content: {
            NavigationView {
                ImportView(fileManager: fileManager, recipeData: $newRecipeData, newIngredient: $newIngredient, saveDisabled: $importSaveDisabled)
                    .navigationTitle(newRecipeData.title == "" ? "Import from Text" : newRecipeData.title)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                importSaveDisabled = true
                                importViewPresented = false
                                newIngredient = ""
                                // reseting newRecipeData
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    newRecipeData.timesCooked = 0
                                    newRecipeData.title = ""
                                    newRecipeData.source = ""
                                    newRecipeData.tags = []
                                    newRecipeData.categories = []
                                    newRecipeData.prepTime = ""
                                    newRecipeData.cookTime = ""
                                    newRecipeData.additionalTime = ""
                                    newRecipeData.totalTime = ""
                                    newRecipeData.notes = ""
                                    newRecipeData.nutrition = ""
                                    newRecipeData.directions = []
                                    newRecipeData.servings = 4
                                    newRecipeData.ingredients = []
                                    newRecipeData.dataImages = []
                                    newRecipeData.date = Date.now
                                }
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                importSaveDisabled = true
                                importViewPresented = false
                                
                                addNotSubmittedIngredient()
                                
                                // saving the new recipe
                                fileManager.saveNewRecipe(newRecipeData: newRecipeData)
                                
                                // reseting newRecipeData
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    newRecipeData.timesCooked = 0
                                    newRecipeData.title = ""
                                    newRecipeData.source = ""
                                    newRecipeData.tags = []
                                    newRecipeData.categories = []
                                    newRecipeData.prepTime = ""
                                    newRecipeData.cookTime = ""
                                    newRecipeData.additionalTime = ""
                                    newRecipeData.totalTime = ""
                                    newRecipeData.notes = ""
                                    newRecipeData.nutrition = ""
                                    newRecipeData.directions = []
                                    newRecipeData.servings = 4
                                    newRecipeData.ingredients = []
                                    newRecipeData.dataImages = []
                                    newRecipeData.date = Date.now
                                    
                                    
                                }
                                
                            }
                            .disabled(importSaveDisabled)
                            
                        }
                    }
            }
        })
    }
    private func addNotSubmittedIngredient() {
        if newIngredient.trimmingCharacters(in: .whitespaces) != "" {
            newRecipeData.ingredients.append(Ingredient(text: newIngredient))
            newIngredient = ""
        }
    }
}

#Preview {
    let fileManager = RecipesManager()
    fileManager.recipes = Recipe.sampleData
    
    return HomeView(fileManager: fileManager)
}


