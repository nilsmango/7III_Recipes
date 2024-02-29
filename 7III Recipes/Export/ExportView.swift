//
//  ExportView.swift
//  7III Recipes
//
//  Created by Simon Lang on 14.02.2024.
//

import SwiftUI

struct ExportView: View {
    @ObservedObject var recipesManager: RecipesManager
    
    var body: some View {
        List {
            Section {
                ShareLink(item: recipesManager.recipesDirectory) {
                    Label("Export all Recipes and Data", systemImage: "square.and.arrow.up.on.square")
                        .tint(.primary)
                }
                        
            NavigationLink(destination: ExportListView(recipesManager: recipesManager)) {
                Label("Select Recipes to Export", systemImage: "square.and.arrow.up")
            }
            }
        }
        .background {
            BackgroundAnimation(backgroundColor: Color(.gray).opacity(0.1), foregroundColor: .blue)
        }
        .navigationTitle("Export Recipes")
        
        
    }
}

#Preview {
    ExportView(recipesManager: RecipesManager())
}
