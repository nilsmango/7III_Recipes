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
    
    @Binding var showImportSheet: Bool
    
    var body: some View {
        Menu {
                
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
                
                Divider()
            
            NavigationLink(destination: ExportView(recipesManager: fileManager)) {
                Label("Export Recipes", systemImage: "square.and.arrow.up")
            }
                
                Button(action: {
                    editViewPresented = true
                }) { Label("Write New Recipe", systemImage: "square.and.pencil")}
                
                Button {
                    importViewPresented = true
                } label: {
                    Label("Import Recipe from Text", systemImage: "text.viewfinder")
                }
                
                Button {
                    // import
                    showImportSheet = true
                } label: {
                    Label("Import File(s)", systemImage: "square.and.arrow.down")
                }
                
                
                
                if !fileManager.trash.isEmpty {
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
    ToolbarOptionsView(fileManager: RecipesManager(), editViewPresented: .constant(false), importViewPresented: .constant(false), showImportSheet: .constant(false))
}
