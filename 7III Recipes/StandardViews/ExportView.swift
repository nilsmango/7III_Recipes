//
//  ExportView.swift
//  7III Recipes
//
//  Created by Simon Lang on 14.02.2024.
//

import SwiftUI

struct ExportView: View {
    @ObservedObject var fileManager: RecipesManager
    
    var body: some View {
        List {
            ShareLink(item: fileManager.recipesDirectory) {
                Label("All", systemImage: "tray.and.arrow.up")
            }
            
            Button(action: {
                
            }, label: {
                Label("By Categories", systemImage: "tray.and.arrow.up")
            })
            
            Button(action: {
                
            }, label: {
                Label("By Tags", systemImage: "tray.and.arrow.up")
            })
            
        }
        
        .background {
            BackgroundAnimation(backgroundColor: Color(.gray).opacity(0.1), foregroundColor: .blue)
        }
        .navigationTitle("Export Recipes")
        
        
    }
}

#Preview {
    ExportView(fileManager: RecipesManager())
}
