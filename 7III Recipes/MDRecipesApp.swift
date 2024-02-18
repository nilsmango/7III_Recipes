//
//  MDRecipesApp.swift
//  MDRecipes
//
//  Created by Simon Lang on 16.03.23.
//

import SwiftUI

@main
struct MDRecipesApp: App {
    @StateObject private var recipesManager = RecipesManager()
    
    @State private var startViewSwitcher: StartViewSwitcher = .normal
    
    @State private var markdownString = ""
    @State private var showSingleHeaderAlert = false
    @State private var recipeData = Recipe.Data()
    
    @State private var showZipImportAlert = false
    @State private var fileURL = ""
    
    var body: some Scene {
        WindowGroup {
            // TODO: maybe add the import things as sheets
            switch startViewSwitcher {
            case .normal:
                StartView(recipesManager: recipesManager)
                    .alert(isPresented: $showSingleHeaderAlert) {
                        Alert(
                            title: Text("Not a 7III Recipe"),
                            message: Text("Couldn't find a 7III Recipe header in this file."),
                            primaryButton: .destructive(Text("Cancel")) {
                                
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
                                // Handle Zip Archive
                                startViewSwitcher = .multiFile
                                do {
                                    try recipesManager.unzipAndCopyRecipesToDisk(url: fileURL)
                                } catch {
                                    print("Error: \(error)")
                                    // TODO: Add error overly here.
                                }
                                startViewSwitcher = .normal
                            },
                            secondaryButton: .destructive(Text("No Thanks")) {
                                // don't do anything.
                            }
                        )
                    }
                    .onAppear {
                        do {
                            try recipesManager.removeInboxAndCopyFolder()
                        } catch {
                            print("Error removing Inbox folder: \(error)")
                            // TODO: Add error overly here.
                        }
                    }
                
                    .onOpenURL { url in
                        do {
                            
                            let fileExtension = url.pathExtension.lowercased()
                            markdownString = try String(contentsOf: url, encoding: .utf8)
                            
                            if fileExtension == "md" {
                                print(url.path)
                                print(recipesManager.recipesDirectory.path)
                                print(url.lastPathComponent)
                                // check if we are coming from our own folder
                                if url.path.contains(recipesManager.recipesDirectory.path) && !url.path.contains("/Inbox/") {
                                    print("now to finding")
                                    // find the recipe in the recipesArray
                                    if let recipeInArray = recipesManager.recipes.first(where: { Parser.sanitizeFileName($0.title) + ".md" == url.lastPathComponent }) {
                                        recipesManager.path = NavigationPath()
                                        recipesManager.path.append("")
                                        recipesManager.path.append(recipeInArray)
                                        startViewSwitcher = .internalFile
                                        
                                    } else {
                                        print("not found")
                                        let recipeStruct = Parser.makeRecipeFromString(string: markdownString)
                                        recipeData = recipeStruct.recipe.data
                                        startViewSwitcher = .singleFile
                                        // remove the file if it is in the inbox folder
                                        do {
                                            try recipesManager.removeItemInInbox(at: URL(fileURLWithPath: url.path))
                                        } catch {
                                            print("Error: \(error)")
                                        }
                                    }
                                    
                                } else {
                                    
                                // check if we have the right header in the file, if not ask if we should import it anyway then make recipe and then recipe.data
                                if Parser.isThere7iiiRecipeHeader(in: markdownString) == false {
                                    showSingleHeaderAlert = true
                                    
                                    
                                } else {
                                    let recipeStruct = Parser.makeRecipeFromString(string: markdownString)
                                    recipeData = recipeStruct.recipe.data
                                    startViewSwitcher = .singleFile
                                    
                                    
                                }
                                    // remove the file if it is in the inbox folder
                                    do {
                                        try recipesManager.removeItemInInbox(at: URL(fileURLWithPath: url.path))
                                    } catch {
                                        print("Error: \(error)")
                                    }
                                }
                                
                                                                
                            } else if fileExtension == "zip" {
                                // ask if user wants to import
                                showZipImportAlert = true
                                fileURL = url.path
                                
                            } else {
                                // Normal folder
                                do {
                                    try recipesManager.importFolderOfRecipes(url: url.path)
                                } catch {
                                    print("Error: \(error)")
                                }
                            }
                            
                        }
                        catch {
                            print("Error opening URL: \(error.localizedDescription)")
                        }
                    }
                
            case .singleFile:
                HomeView(recipesManager: recipesManager, editViewPresented: true, newRecipeData: recipeData, comingFromImportView: true)

            case .internalFile:
                HomeView(recipesManager: recipesManager)

            case .multiFile:
                Text("Importing Files...")
            }
        }
    }
}
