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

    var body: some View {
        NavigationView {
            List {
                ForEach(fileManager.markdownFiles) { recipe in
                    NavigationLink(destination: RecipeView(recipe: recipe)) {
                            // TODO: show tags, how long it takes etc.
                            ListItemView(recipe: recipe)
                    }
                    
                }
                .onDelete { indexSet in
                    fileManager.delete(at: indexSet)
                }
                .onMove { indexSet, newPlace in
                    fileManager.move(from: indexSet, to: newPlace)
                }
            }
            .navigationTitle("MD Recipes")
            
            .toolbar {
                EditButton()
                Button(action: {
                    // options
                }) { Label("Options", systemImage: "ellipsis.circle")}
                
                Button(action: {
                    // TODO: change that to an edit view / see qrCoder
                    fileManager.createMarkdownFile(name: "New Recipe", content: "")
                }) { Label("New Recipe", systemImage: "plus.circle")}
            }
            .environment(\.editMode, $editMode)
            
            
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
