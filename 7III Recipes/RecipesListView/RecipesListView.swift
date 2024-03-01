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
            if fileManager.filterTheRecipes(string: "", ingredients: [], categories: category.isEmpty ? [] : [category], tags: []).count > 1 {
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
            label: {
                Label("Sort by", systemImage: "arrow.up.arrow.down.circle")
                    .labelStyle(.iconOnly)
            }
            }
            
            
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
    }
}

#Preview {
    let fileManager = RecipesManager()
    fileManager.recipes = Recipe.sampleData
    
    return RecipesListView(fileManager: fileManager, category: "Main Course")
}
