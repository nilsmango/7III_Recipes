//
//  HomeView.swift
//  MDRecipes
//
//  Created by Simon Lang on 20.03.23.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var recipesManager: RecipesManager
    @Environment(\.scenePhase) private var scenePhase
    
    @State var searchText = ""
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    // Edit Things
    @Binding var editViewPresented: Bool
    @Binding var newRecipeData: Recipe.Data
    @Binding var comingFromImportView: Bool
    
    @State private var newIngredient = ""
    
    @State private var importViewPresented = false
    
    @State private var importSaveDisabled = true
    
    @State private var showNewRecipeButtons = false
    
    @State private var showImportSheet = false
    
    var body: some View {
        NavigationStack(path: $recipesManager.path) {
            if searchText.isEmpty {
                ScrollView {
                    
                    VStack(alignment: .leading) {
                        let allRecipes = recipesManager.filterTheRecipes(string: "", ingredients: [], categories: [], tags: []).count
                        
                        if allRecipes > 0 {
                            Text("7III Recipes")
                                .font(.title3)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                                .padding([.horizontal, .top])
                            LazyVGrid(columns: columns) {
                                Button {
                                    recipesManager.path.append("")
                                    // updating our navigation tools
                                    recipesManager.currentCategory = "All"
                                    recipesManager.chosenTags = []
                                } label: {
                                    FolderView(categoryFolder: "All", categoryNumber: String(allRecipes))
                                }
                                
                                ForEach(recipesManager.getAllCategories(), id: \.self) { category in
                                    Button {
                                        recipesManager.path.append(category)
                                        // updating our navigation tools
                                        recipesManager.currentCategory = category
                                        recipesManager.chosenTags = []
                                    } label: {
                                        FolderView(categoryFolder: category, categoryNumber: String(recipesManager.filterTheRecipes(string: "", ingredients: [], categories: [category], tags: []).count))
                                    }
                                }
                                
                                if allRecipes > 1 {
                                    Button {
                                        recipesManager.path.append(recipesManager.randomRecipe()!)
                                        // updating our navigation tools
                                        recipesManager.currentCategory = "All"
                                        recipesManager.chosenTags = []
                                    } label: {
                                        RandomRecipeView()
                                    }
                                }
                            }
                            .padding([.horizontal])
                            
                            let allTags = recipesManager.getAllTags()
                            if allTags.count > 0 {
                                Text("Tags")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                                    .padding([.horizontal, .top])
                                
                                FlexiTagsView(recipesManager: recipesManager, strings: allTags)
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
                                    Label("From Text", systemImage: "text.viewfinder")
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
                .navigationDestination(for: String.self) { category in
                    RecipesListView(fileManager: recipesManager, category: category)
                }
                
                .navigationDestination(for: Recipe.self) { recipe in
                    RecipeView(recipesManager: recipesManager, recipe: recipe)
                }
                
                .background(
                    .gray.opacity(0.1)
                    //                    BackgroundAnimation(backgroundColor: .gray.opacity(0.1), withLogo: false, foregroundColor: .blue)
                )
                //                .navigationTitle("Categories")
                .toolbar {
                    
                    ToolbarOptionsView(fileManager: recipesManager, editViewPresented: $editViewPresented, importViewPresented: $importViewPresented, showImportSheet: $showImportSheet)
                }
                
            } else {
                HomeListView(recipesManager: recipesManager, searchText: searchText)
            }
        }
        .scrollContentBackground(.hidden)
        .searchable(text: $searchText)
        
        .background(ignoresSafeAreaEdges: .all)
        // making the font rounded
        .customNavBar()
        .onChange(of: scenePhase) { phase in
            if phase == .inactive {
                // saving our timer status to disk
                recipesManager.saveTimersAndTrashToDisk()
            }
        }
        .fullScreenCover(isPresented: $editViewPresented, content: {
            NavigationView {
                RecipeEditView(recipeData: $newRecipeData, fileManager: recipesManager, newIngredient: $newIngredient, comingFromImportView: comingFromImportView)
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
                                
                                comingFromImportView = false
                            }
                            .tint(.red)

                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                editViewPresented = false
                                
                                addNotSubmittedIngredient()
                                
                                // saving the new recipe
                                recipesManager.saveNewRecipe(newRecipeData: newRecipeData)
                                
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
                                comingFromImportView = false
                                
                            }
                        }
                    }
            }
        })
        .fullScreenCover(isPresented: $importViewPresented, content: {
            NavigationView {
                ImportFromTextView(fileManager: recipesManager, recipeData: $newRecipeData, newIngredient: $newIngredient, saveDisabled: $importSaveDisabled)
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
                            .tint(.red)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                importSaveDisabled = true
                                importViewPresented = false
                                
                                addNotSubmittedIngredient()
                                
                                // saving the new recipe
                                recipesManager.saveNewRecipe(newRecipeData: newRecipeData)
                                
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
        .fileImporter(isPresented: $showImportSheet, allowedContentTypes: [.folder, .zip, .text]) { url in
            // do something
        }
    }
    private func addNotSubmittedIngredient() {
        if newIngredient.trimmingCharacters(in: .whitespaces) != "" {
            newRecipeData.ingredients.append(Ingredient(text: newIngredient))
            newIngredient = ""
        }
    }
}

#Preview {

    return HomeView(recipesManager: RecipesManager(), editViewPresented: .constant(false), newRecipeData: .constant(Recipe.sampleData.first!.data), comingFromImportView: .constant(false))
}
