//
//  ToolbarOptionsView.swift
//  7III Recipes
//
//  Created by Simon Lang on 29.11.23.
//

import SwiftUI

struct ToolbarOptionsView: View {
    @ObservedObject var fileManager: RecipesManager
    
    @Binding var editViewPresented: Bool
    
    @Binding var importViewPresented: Bool
    
    @Binding var sortingSelection: Sorting
    
    var isHomeView: Bool
    
    var body: some View {
        Menu {
            NavigationLink(destination: ExportView(recipesManager: fileManager)) {
                Label("Export Recipes", systemImage: "square.and.arrow.up")
            }
            
            NavigationLink(destination: AboutView()) {
                Label("About", systemImage: "info.circle")
            }
            
            NavigationLink(destination: PrivacyView()) {
                Label("Privacy Notice", systemImage: "doc.text.magnifyingglass")
            }
            
            Button(action: {
                // TODO: Add donation thing
            }) {
                Label("Tip us 1 USD!", systemImage: "heart")
            }
            if !isHomeView {
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
            }
            
            Button(action: {
                editViewPresented = true
            }) { Label("Write New Recipe", systemImage: "square.and.pencil")}
            
            Button {
                importViewPresented = true
            } label: {
                Label("Import Recipe from Text", systemImage: "square.and.arrow.down")
            }
            if !fileManager.trash.isEmpty && isHomeView {
                NavigationLink(destination: TrashList(fileManager: fileManager)) {
                    Label("Show Trash", systemImage: "trash")
                }
            }
            
        } label: {
            Label("Options", systemImage: "ellipsis.circle")
                .labelStyle(.iconOnly)
        }
    }
}

#Preview {
    ToolbarOptionsView(fileManager: RecipesManager(), editViewPresented: .constant(false), importViewPresented: .constant(false), sortingSelection: .constant(.standard), isHomeView: true)
}
