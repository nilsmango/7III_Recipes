//
//  MarkdownBrowserView.swift
//  MDRecipes
//
//  Created by Simon Lang on 16.03.23.
//

import SwiftUI

struct RecipesListView: View {
    @ObservedObject var fileManager: MarkdownFileManager
    
    @State private var editMode: EditMode = .inactive
    
    @State private var sortingSelection: Sorting = .manual
    
    @AppStorage("Servings") var chosenServings = 4

    var category: String
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(fileManager.filterTheRecipes(string: "", ingredients: [], categories: category.isEmpty ? [] : [category], tags: [])) { recipe in
                    NavigationLink(destination: RecipeView(fileManager: fileManager, recipe: recipe, chosenServings: chosenServings)) {
                            // TODO: show tags, how long it takes etc.
                        ListItemView(recipe: recipe)
                    }
                    
                }
                .onDelete { indexSet in
                    fileManager.delete(at: indexSet)
                }
                .onMove { indexSet, newPlace in
                    fileManager.move(from: indexSet, to: newPlace)
                    sortingSelection = .manual
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
                                Text(sortCase.rawValue.capitalized)
                            }
                        }
                    }
                     label: {
                      
                             Label("Sort by", systemImage: "arrow.up.arrow.down")
                            
                    }
                    
                    
                } label: {
                    Label("Options", systemImage: "ellipsis.circle")
                        .labelStyle(.iconOnly)
                        
                }
                
                
                Button(action: {
                    // TODO: change that to an edit view / see qrCoder
                    fileManager.createMarkdownFile(name: "New Recipe", content: "# Curry\n\nSource:\nTags: #wichtig, #bad\nKategorien: Main Course\nRating: 1/5\nPrep time: 30min\nCook time:\nAdditional time:\nTotal time: 1h40min\nServings:\n\n## Zutaten\n- [ ] 200g rote Linsen\n- [ ] 250ml Kokosmilch\n- [ ] 2 Karotten\n- [ ] 2 Kartoffeln\n- [ ] 20g Koriander\n- [ ] 1 Zwiebel (groß)\n- [ ] 3 Zehen Knoblauch\n- [ ] 1 Chili (rot)\n- [ ] 15g Ingwer\n- [ ] 1 EL Tomatenmark\n- [ ] 4 TL Koriandersaat (gemahlen)\n- [ ] 2 TL Kreuzkümmel (gemahlen)\n- [ ] 2 TL Kurkuma\n- [ ] 2 TL Garam masala Gewürzmischung\n- [ ] 800ml Gemüsebrühe\n- [ ] Salz\n- [ ] Zucker\n- [ ] Zitronensaft\n- [ ] Butter zum Anbraten\n\n## Directions\n1. Take the lime and the coconut\n2. Drink it all up\n3. Call me in the morning\n\nEnjoy!")
                }) { Label("New Recipe", systemImage: "plus.circle")}
            }
            .environment(\.editMode, $editMode)
            
            .onChange(of: sortingSelection) { newSortingSelection in
                fileManager.sortRecipes(selection: newSortingSelection)
            }
        }
    }
}


struct RecipesListView_Previews: PreviewProvider {
    static var previews: some View {
        let fileManager = MarkdownFileManager()
        fileManager.markdownFiles = MarkdownFile.sampleData
        
        return RecipesListView(fileManager: fileManager, category: "Main Course")
    }
}
