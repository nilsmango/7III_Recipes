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

    
    var body: some View {
        NavigationView {
            List {
                ForEach(fileManager.markdownFiles) { recipe in
                    NavigationLink(destination: RecipeView(recipe: recipe)) {
                            // TODO: show tags, how long it takes etc.
                        ListItemView(fileManager: fileManager, recipe: recipe)
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
            .navigationTitle("MD Recipes")
            
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
                    fileManager.createMarkdownFile(name: "New Recipe", content: "")
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
        
        return RecipesListView(fileManager: fileManager)
    }
}
