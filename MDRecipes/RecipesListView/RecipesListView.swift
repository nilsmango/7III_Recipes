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
    
    
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(fileManager.filterTheRecipes(string: "", ingredients: [], categories: category.isEmpty ? [] : [category], tags: [])) { recipe in
                    NavigationLink(destination: RecipeView(fileManager: fileManager, recipe: recipe)) {
                        // TODO: show tags, how long it takes etc.
                        ListItemView(recipe: recipe)
                    }
                    .listStyle(.insetGrouped)
                    
                }
                .onDelete { indexSet in
                    fileManager.delete(at: indexSet)
                }
                .onMove { indexSet, newPlace in
                    fileManager.move(from: indexSet, to: newPlace)
                    sortingSelection = .standard
                }
            }
            .navigationTitle(Text(category.isEmpty ? "All" : category))
            
            
            .toolbar {
                // TODO: check if I don't need the editButton to move things
                //                EditButton()
                Menu {
                    
                    Button(action: {  } ) {
                        Label("About", systemImage: "info.circle")
                    }
                    Button(action: {
                        // TODO: Add donation thing
                    } ) {
                        Label("Tip us 1 USD!", systemImage: "heart")
                    }
                    
                    Menu {
                        Picker("Sorting", selection: $sortingSelection) {
                            ForEach(Sorting.allCases) { sortCase in
                                if sortCase == .cooked {
                                    Text("Times Cooked")
                                } else if sortCase == .time {
                                    Text("Total Time")
                                } else {
                                    Text(sortCase.rawValue.capitalized)
                                }
                                
                            }
                        }
                    }
                label: { Label("Sort by", systemImage: "arrow.up.arrow.down") }
                    
                } label: {
                    Label("Options", systemImage: "ellipsis.circle")
                        .labelStyle(.iconOnly)
                }
                Menu {
                    Button(action: {
                        editViewPresented = true
                    }) { Label("Write Yourself", systemImage: "square.and.pencil")}
                    
                    
                    
                    Button {
                        importViewPresented = true
                    } label: {
                        Label("Import from Text", systemImage: "square.and.arrow.down")
                    }
                    Button(action: {
                        let name = "Curry No. \(Int.random(in: 0...1000))"
                        let filename = Parser.sanitizeFileName(name)
                        fileManager.createMarkdownFile(name: filename, content: "# \(name)\n\nSource:\nTags: #wichtig, #bad\nKategorien: Main Course\nRating: \(Int.random(in: 1...5))/5\nPrep time: 30min\nCook time:\nAdditional time:\nTotal time: \(Int.random(in: 1...4))h\(Int.random(in: 1...49))min\nServings: 4\nTimes Cooked: \(Int.random(in: 0...9))\n\n## Zutaten\n- [ ] 200g rote Linsen\n- [ ] 250ml Kokosmilch\n- [ ] 2 Karotten\n- [ ] 2 Kartoffeln\n- [ ] 20g Koriander\n- [ ] 1 Zwiebel (groß)\n- [ ] 3 Zehen Knoblauch\n- [ ] 1 Chili (rot)\n- [ ] 15g Ingwer\n- [ ] 1 EL Tomatenmark\n- [ ] 4 TL Koriandersaat (gemahlen)\n- [ ] 2 TL Kreuzkümmel (gemahlen)\n- [ ] 2 TL Kurkuma\n- [ ] 2 TL Garam masala Gewürzmischung\n- [ ] 800ml Gemüsebrühe\n- [ ] Salz\n- [ ] Zucker\n- [ ] Zitronensaft\n- [ ] Butter zum Anbraten\n\n## Directions\n1. Take the lime and the coconut\n2. Drink it all up\n3. Call me in the morning after \(Int.random(in: 2...40)) minutes.\n\nEnjoy!")
                        // add the timers to our timer manager also
                        if let recipe = fileManager.recipes.last {
                            fileManager.loadTimers(for: recipe)
                        }
                        // save the fake recipe to markdown folder
                        fileManager.saveRecipeAsMarkdownFile(recipe: fileManager.recipes.last!)
                        
                    }) { Label("New Fake Recipe", systemImage: "hammer.circle")}
                    
                    
                } label: {
                    Label("New Recipe", systemImage: "plus.circle")
                }
                
                
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
                    RecipeEditView(recipeData: $newRecipeData, fileManager: fileManager)
                        .navigationTitle(newRecipeData.title == "" ? "New Recipe" : newRecipeData.title)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Dismiss") {
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
                                        newRecipeData.images = ""
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
                                        newRecipeData.images = ""
                                        newRecipeData.date = Date.now
                                        
                                    }
                                    
                                }
                            }
                        }
                }
            })
            .fullScreenCover(isPresented: $importViewPresented, content: {
                NavigationView {
                    ImportView(recipeData: $newRecipeData)
                        .navigationTitle(newRecipeData.title == "" ? "New Recipe" : newRecipeData.title)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Dismiss") {
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
                                        newRecipeData.images = ""
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
                                        newRecipeData.images = ""
                                        newRecipeData.date = Date.now
                                        
                                    }
                                    
                                }
                            }
                        }
                }
            })
        }
    }
}


struct RecipesListView_Previews: PreviewProvider {
    static var previews: some View {
        let fileManager = RecipesManager()
        fileManager.recipes = Recipe.sampleData
        
        return RecipesListView(fileManager: fileManager, category: "Main Course")
    }
}
