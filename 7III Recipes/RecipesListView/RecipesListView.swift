//
//  MarkdownBrowserView.swift
//  MDRecipes
//
//  Created by Simon Lang on 16.03.23.
//

import SwiftUI

struct RecipesListView: View {
    @ObservedObject var fileManager: RecipesManager
    
    @State private var editMode: EditMode = .inactive
    
    @AppStorage("sorting") private var sortingSelection: Sorting = .standard
    
    var category: String
    
    @State private var editViewPresented = false
    
    @State private var importViewPresented = false
    
    @State private var newRecipeData = Recipe.Data()
    
    @State private var saveDisabled = true
    
    @State private var newIngredient = ""
    
    var body: some View {
        //        NavigationStack {
        List {
            ForEach(fileManager.filterTheRecipes(string: "", ingredients: [], categories: category.isEmpty ? [] : [category], tags: [])) { recipe in
                NavigationLink(value: recipe) {
                    ListItemView(recipe: recipe)
                }
            }
            .onDelete { indexSet in
                fileManager.delete(at: indexSet, filteringCategory: category)
            }
            .onMove { indexSet, newPlace in
                fileManager.move(from: indexSet, to: newPlace)
                sortingSelection = .standard
            }
            
        }
        .listStyle(.insetGrouped)
        .background(
            .gray
                .opacity(0.1)
        )
        .navigationTitle(Text(category.isEmpty ? "All" : category))

        .toolbar {
            
            
            ToolbarOptionsView(fileManager: fileManager, editViewPresented: $editViewPresented, importViewPresented: $importViewPresented, sortingSelection: $sortingSelection, isHomeView: false)
            
            //                Button(action: {
            //                    let name = "Curry No. \(Int.random(in: 0...1000))"
            //                    let filename = Parser.sanitizeFileName(name)
            //                    recipesManager.createMarkdownFile(name: filename, content: "# \(name)\n\nSource:\nTags: #wichtig, #bad\nCategories: Main Course\nRating: \(Int.random(in: 1...5))/5\nPrep time: 30min\nCook time: 5 min\nAdditional time: 1h\nTotal time: \(Int.random(in: 1...4))h\(Int.random(in: 1...49))min\nServings: 6\nTimes Cooked: \(Int.random(in: 0...9))\n\n## Ingredients\n- [ ] 200g rote Linsen\n- [ ] 250ml Kokosmilch\n- [ ] 2 Karotten\n- [ ] 2 Kartoffeln\n- [ ] 20g Koriander\n- [ ] 1 Zwiebel (groß)\n- [ ] 3 Zehen Knoblauch\n- [ ] 1 Chili (rot)\n- [ ] 15g Ingwer\n- [ ] 1 EL Tomatenmark\n- [ ] 4 TL Koriandersaat (gemahlen)\n- [ ] 2 TL Kreuzkümmel (gemahlen)\n- [ ] 2 TL Kurkuma\n- [ ] 2 TL Garam masala Gewürzmischung\n- [ ] 800ml Gemüsebrühe\n- [ ] Salz\n- [ ] Zucker\n- [ ] Zitronensaft\n- [ ] Butter zum Anbraten\n\n## Directions\n1. Take the lime and the coconut\n2. Drink it all up\n3. Call me in the morning after \(Int.random(in: 2...40)) minutes.\n\nEnjoy!")
            //                    // add the timers to our timer manager also
            //                    if let recipe = recipesManager.recipes.last {
            //                        recipesManager.loadTimers(for: recipe)
            //                    }
            //                    // save the fake recipe to markdown folder
            //                    recipesManager.saveRecipeAsMarkdownFile(recipe: recipesManager.recipes.last!)
            //
            //                }) { Label("New Fake Recipe", systemImage: "hammer.circle")}
            
        }
        .environment(\.editMode, $editMode)
        
        .onChange(of: sortingSelection) { newSortingSelection in
            fileManager.sortRecipes(selection: newSortingSelection)
        }
        .onAppear {
            fileManager.sortRecipes(selection: sortingSelection)
        }
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
                ImportView(fileManager: fileManager, recipeData: $newRecipeData, newIngredient: $newIngredient, saveDisabled: $saveDisabled)
                    .navigationTitle(newRecipeData.title == "" ? "Import from Text" : newRecipeData.title)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
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
                                saveDisabled = true
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
                            .disabled(saveDisabled)
                            
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
    //    }
}

#Preview {
    let fileManager = RecipesManager()
    fileManager.recipes = Recipe.sampleData
    
    return RecipesListView(fileManager: fileManager, category: "Main Course")
}
