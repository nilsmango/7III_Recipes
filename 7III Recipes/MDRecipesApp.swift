//
//  MDRecipesApp.swift
//  MDRecipes
//
//  Created by Simon Lang on 16.03.23.
//

import SwiftUI

@main
struct MDRecipesApp: App {
    @StateObject private var fileManager = RecipesManager()
    
    @State private var startViewSwitcher: StartViewSwitcher = .normal
    
    @State private var markdownString = ""
    @State private var showSingleHeaderAlert = false
    
    @State private var recipeData = Recipe.Data()
    @State private var textFieldIngredient = ""
    
    @State private var showZipImportAlert = false
    @State private var fileURL = ""
    
    var body: some Scene {
        WindowGroup {
            // TODO: maybe add the import things as sheets
            switch startViewSwitcher {
            case .normal:
                StartView(fileManager: fileManager)
                    .alert(isPresented: $showSingleHeaderAlert) {
                        Alert(
                            title: Text("Not a 7III Recipe"),
                            message: Text("Couldn't find a 7III Recipe header in this file."),
                            primaryButton: .destructive(Text("Cancel")) {
                                // don't do anything.
                            },
                            secondaryButton: .default(Text("Try Anyway")) {
                                let recipeStruct = Parser.makeRecipeFromString(string: markdownString)
                                recipeData = recipeStruct.recipe.data
                                startViewSwitcher = .singleFile
                            }
                        )
                    }
                    .alert(isPresented: $showZipImportAlert) {
                        Alert(
                            title: Text("Import Recipes?"),
                            message: Text("Do you want to try to import the recipes in the zip archive?"),
                            primaryButton: .default(Text("Yes")) {
                                // TODO: Handle Zip archive
                                // Might use startViewSwitcher = .multiFile to show how many etc?
                                do {
                                    try fileManager.unzipAndCopyRecipesToDisk(url: fileURL)
                                } catch {
                                    print("Error: \(error)")
                                    // TODO: Add error overly here.
                                }
                            },
                            secondaryButton: .destructive(Text("No Thanks")) {
                                // don't do anything.
                            }
                        )
                    }
                
                    .onOpenURL { url in
                        do {
                            
                            let fileExtension = url.pathExtension.lowercased()
                            
                            if fileExtension == "md" {
                                // Handle Markdown file
                                markdownString = try String(contentsOf: url, encoding: .utf8)
                                // check if we have the right header in the file, if not ask if we should import it anyway then make recipe and then recipe.data
                                if Parser.isThere7iiiRecipeHeader(in: markdownString) == false {
                                    showSingleHeaderAlert = true
                                } else {
                                    let recipeStruct = Parser.makeRecipeFromString(string: markdownString)
                                    recipeData = recipeStruct.recipe.data
                                    startViewSwitcher = .singleFile
                                }
                                                                
                            } else if fileExtension == "zip" {
                                // ask if user wants to import
                                showZipImportAlert = true
                                fileURL = url.path
                                
                            } else {
                                // Handle other file types as needed
                                print("Unsupported file type")
                            }
                            
                        }
                        catch {
                            print("Error opening URL: \(error.localizedDescription)")
                        }
                    }
                
            case .singleFile:
                NavigationView {
                    RecipeEditView(recipeData: $recipeData, fileManager: fileManager, newIngredient: $textFieldIngredient)
                        .navigationTitle("Import Recipe")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(role: .destructive) {
                                    startViewSwitcher = .normal
                                    textFieldIngredient = ""
                                } label: {
                                    Text("Cancel")
                                }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Save") {
                                    
                                    startViewSwitcher = .normal
                                    
                                    if textFieldIngredient.trimmingCharacters(in: .whitespaces) != "" {
                                        recipeData.ingredients.append(Ingredient(text: textFieldIngredient))
                                        textFieldIngredient = ""
                                    }
                                    
                                    // saving the new recipe
                                    fileManager.saveNewRecipe(newRecipeData: recipeData)
                                }
                            }
                        }
                }
            case .multiFile:
                Text("multifile")
            }
        }
    }
}