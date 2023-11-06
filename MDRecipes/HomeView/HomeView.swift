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
    
    @State private var importViewPresented = false
    
    @State private var newRecipeData = Recipe.Data()
    
    @State private var importSaveDisabled = true
    
    var body: some View {
        NavigationStack {
            if searchText.isEmpty {
                ScrollView {
                    VStack {
                        LazyVGrid(columns: columns) {
                            NavigationLink(destination: RecipesListView(fileManager: fileManager, category: "")) {
                                FolderView(categoryFolder: "All", categoryNumber: String(fileManager.filterTheRecipes(string: "", ingredients: [], categories: [], tags: []).count))
                            }
                            
                            ForEach(fileManager.getAllCategories(), id: \.self) { category in
                                NavigationLink(destination: RecipesListView(fileManager: fileManager, category: category)) {
                                    FolderView(categoryFolder: category, categoryNumber: String(fileManager.filterTheRecipes(string: "", ingredients: [], categories: [category], tags: []).count))
                                    
                                }
                                
                            }
                            if randomRecipe != nil {
                                NavigationLink(destination: RecipeView(fileManager: fileManager, recipe: randomRecipe!)) {
                                    RandomRecipeView()
                                    
                                }
                            }
                            
                        }
                        
                        .padding()
                      
                    // TODO: make this great
                        
                        Text("Tags")
                        FlexiStringsView(strings: fileManager.getAllTags())
                        Text("Ingredients")
                        
                        
                        Text("Irgndwie Tags und ingredients here, wenn clickt dann zu einer speziellen liste mit ausgewählten tags oder eben ingredients, wo man einzelne tags oder ingredients dazuklicken kann wie TagsEditView - die neue liste hier unten hinzufügen bei else")
                        
                        Text("New Recipe Button auch irgendwo hier unten, als erstes!(?)")
                        Text("Alles wie in erinnerungen app")
                        NavigationLink("Trash", destination: TrashList(fileManager: fileManager))
                        
                        
                    }
                }
                
                .background(
                    .gray
                    .opacity(0.1)
                )
//                .navigationTitle("Categories")
                .toolbar {
                    Menu {
                        Button(action: {  } ) {
                            Label("About", systemImage: "info.circle")
                        }
                        Button(action: {
                            // TODO: Add donation thing
                        } ) {
                            Label("Tip us 1 USD!", systemImage: "heart")
                        }
                        Button(action: {
                            editViewPresented = true
                        }) { Label("Write New Recipe", systemImage: "square.and.pencil")}
                        
                        
                        
                        Button {
                            importViewPresented = true
                        } label: {
                            Label("Import Recipe from Text", systemImage: "square.and.arrow.down")
                        }
                    } label: {
                        Label("Options", systemImage: "ellipsis.circle")
                            .labelStyle(.iconOnly)
                    }
                }
                
            } else {
                List {
                          ForEach(fileManager.getAllCategories(), id: \.self) { category in
                            if !fileManager.filterTheRecipes(string: searchText, ingredients: [], categories: [category], tags: []).isEmpty {
                                Section {
                                    ForEach(fileManager.filterTheRecipes(string: searchText, ingredients: [], categories: [category], tags: [])) { recipe in
                                        NavigationLink(destination: RecipeView(fileManager: fileManager, recipe: recipe)) {
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
        
        .fullScreenCover(isPresented: $editViewPresented, content: {
            NavigationView {
                RecipeEditView(recipeData: $newRecipeData, fileManager: fileManager)
                    .navigationTitle(newRecipeData.title == "" ? "New Recipe" : newRecipeData.title)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                editViewPresented = false
                                
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
                ImportView(fileManager: fileManager, recipeData: $newRecipeData, saveDisabled: $importSaveDisabled)
                    .navigationTitle(newRecipeData.title == "" ? "New Recipe" : newRecipeData.title)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                importViewPresented = false
                                
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
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
            let fileManager = RecipesManager()
            fileManager.recipes = Recipe.sampleData
            
        return HomeView(fileManager: fileManager)
        }
    }

