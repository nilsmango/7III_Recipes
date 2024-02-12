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
                                startViewSwitcher = .normal
                            },
                            secondaryButton: .default(Text("Try Anyway")) {
                                let recipeStruct = Parser.makeRecipeFromString(string: markdownString)
                                recipeData = recipeStruct.recipe.data
                                startViewSwitcher = .singleFile
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
                                // Handle Zip archive
                                // try handleZipFile(url: url)
                                print("zip!")
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
