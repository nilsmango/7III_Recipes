//
//  ImportFromTextView.swift
//  MDRecipes
//
//  Created by Simon Lang on 02.04.23.
//

import SwiftUI

struct ImportFromTextView: View {
    @StateObject var importer = Importer()
    
    @ObservedObject var fileManager: RecipesManager
    
    // Segments View
    @State private var showingSheet = false
    
    // edit view data
    @Binding var recipeData: Recipe.Data
    @Binding var newIngredient: String
    
    // saving disabled
    @Binding var saveDisabled: Bool
    
    // indexes parsed
    @State private var indexes = [Int]()
    
    @State private var counter = 0
    
    @State private var recipeLanguage: RecipeLanguage = .english
    
    @State private var newRecipe = ""
    
    var body: some View {
        if counter < 100 || showingSheet {
            List {
                Section(header: Text("Paste Recipe Text here"), footer: Text("Make sure in the text editor above, title, ingredients and instructions are all on separate lines and ingredients and instructions are titled as such. Then press the decode button below")) {
                    TextEditor(text: $newRecipe)
                        .frame(minHeight: 370)
                    
                }
                
                Section {
                    Button {
                        counter += 1
                        
                        importer.recipeSegments = Parser.makeSegmentsFromString(string: newRecipe)
                        
                        showingSheet = true
                        
                    } label: {
                        Label(counter > 0 ? "Update" : "Decode", systemImage: "wand.and.stars")
                    }
                    .disabled(newRecipe.isEmpty)
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                .gray
                    .opacity(0.1)
            )

            .onAppear {
                saveDisabled = true
            }
            .fullScreenCover(isPresented: $showingSheet, content: {
                NavigationView {
                    SegmentsImportView(importer: importer, recipeLanguage: $recipeLanguage)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Back to Text") {
                                    showingSheet = false
                                }
                                .tint(.red)

                            }
                            
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Continue") {
                                    
                                    recipeData = Parser.makeDataFromSegments(segments: importer.recipeSegments, language: recipeLanguage)
                                    
                                    showingSheet = false
                                    counter = 101
                                    saveDisabled = false
                                    
                                }
                            }
                        }
                }
            })
            
        } else {
            RecipeEditView(recipeData: $recipeData, fileManager: fileManager, newIngredient: $newIngredient, comingFromImportView: true)
        }
    }
}

#Preview {
        ImportFromTextView(importer: Importer(), fileManager: RecipesManager(), recipeData: .constant(Recipe.sampleData[0].data), newIngredient: .constant(""), saveDisabled: .constant(true))
}
