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
    
    // Edit Things
    @Binding var editViewPresented: Bool
    @Binding var newRecipeData: Recipe.Data
    @Binding var comingFromImportView: Bool
    
    @State private var newIngredient = ""
    
    @State private var importViewPresented = false
    
    @State private var importSaveDisabled = true
    
    @State private var showImportSheet = false
    
    @State private var markdownString = ""
    @State private var showSingleHeaderAlert = false
    
    // Folder/ZIP import
    @State private var showRecipesImportAlert = false
    @State private var fileURL = ""
    
    // Import Overlay
    @State private var showAlertOverlay = false
    @State private var alertOverlayText = ""
    
    
    var body: some View {
        NavigationStack(path: $recipesManager.path) {
            if searchText.isEmpty {
                HomeRecipesFolderView(recipesManager: recipesManager, editViewPresented: $editViewPresented, importViewPresented: $importViewPresented)
                    .navigationDestination(for: String.self) { category in
                        RecipesListView(fileManager: recipesManager, category: category)
                    }
                    .navigationDestination(for: Recipe.self) { recipe in
                        RecipeView(recipesManager: recipesManager, recipe: recipe)
                    }
                    .background(
                        .gray.opacity(0.1)
                    )
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
        .alert(isPresented: $showSingleHeaderAlert) {
            Alert(
                title: Text("Not a 7III Recipe"),
                message: Text("Couldn't find a 7III Recipe header in this file."),
                primaryButton: .destructive(Text("Cancel")) {
                    
                },
                secondaryButton: .default(Text("Try Anyway")) {
                    let recipeStruct = Parser.makeRecipeFromString(string: markdownString)
                    newRecipeData = recipeStruct.recipe.data
                    comingFromImportView = true
                    editViewPresented = true
                }
            )
        }
        .overlay {
            ImportRecipesOverlay(recipesManager: recipesManager, showOverlay: $showRecipesImportAlert, fileURL: fileURL)
            AlertOverlay(showAlert: $showAlertOverlay, text: alertOverlayText)
            // tags
            RenameTagOverlay(recipesManager: recipesManager)
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
        .fileImporter(isPresented: $showImportSheet, allowedContentTypes: [.folder, .zip, .text]) { result in
            switch result {
            case .success(let url):
                // gain access to the directory
                _ = url.startAccessingSecurityScopedResource()
                do {
                    let fileExtension = url.pathExtension.lowercased()
                    
                    if fileExtension == "md" {
                        // check if we are coming from our own folder
                        if url.path.contains(recipesManager.recipesDirectory.path) && !url.path.contains("/Inbox/") {

                            // find the recipe in the recipesArray open it if it's in there
                            let foundRecipe = recipesManager.findAndGoToInternalRecipe(url: url)
                            
                            // if not found try to import the recipe
                            if foundRecipe == false {
                                markdownString = try String(contentsOf: url, encoding: .utf8)
                                let recipeStruct = Parser.makeRecipeFromString(string: markdownString)
                                newRecipeData = recipeStruct.recipe.data
                                comingFromImportView = true
                                editViewPresented = true
                                // remove the file if it is in the inbox folder
                                do {
                                    try recipesManager.removeItemInInbox(at: URL(fileURLWithPath: url.path))
                                } catch {
                                    print("Error: \(error)")
                                }
                            }
                            
                        } else {
                            markdownString = try String(contentsOf: url, encoding: .utf8)
                            // check if we have the right header in the file, if not ask if we should import it anyway then make recipe and then recipe.data
                            if Parser.isThere7iiiRecipeHeader(in: markdownString) == false {
                                showSingleHeaderAlert = true
                            }
                            else {
                                let recipeStruct = Parser.makeRecipeFromString(string: markdownString)
                                newRecipeData = recipeStruct.recipe.data
                                comingFromImportView = true
                                editViewPresented = true
                                
                            }
                            // remove the file if it is in the inbox folder
                            do {
                                try recipesManager.removeItemInInbox(at: URL(fileURLWithPath: url.path))
                            } catch {
                                print("Error: \(error)")
                            }
                        }
                    } else {
                        // we have either zip or folder
                        fileURL = url.path
                        showRecipesImportAlert = true
                    }
                }
                
                catch {
                    // Showing the alert
                    alertOverlayText = "Error opening file: \(error.localizedDescription)\n\nIf you tried to import a file, use \"Import File(s)\" in the menu instead."
                    showAlertOverlay = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 300) {
                    url.stopAccessingSecurityScopedResource()
                }
                
            case .failure(let error):
                print("Error selecting file: \(error.localizedDescription)")
            }
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
