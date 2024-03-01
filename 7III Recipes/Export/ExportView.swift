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
        VStack {
                ShareLink(item: recipesManager.recipesDirectory) {
                    Label("Export all Recipes and Data", systemImage: "square.and.arrow.up.on.square")
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(Color("FolderBG"))
                        )
                }
                .padding(.bottom)
                        
            NavigationLink(destination: ExportListView(recipesManager: recipesManager)) {
                Label("Select Recipes to Export", systemImage: "square.and.arrow.up")
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(Color("FolderBG"))
                    )
                
            }
            }
        .padding()
        .frame(height: UIScreen.main.bounds.height)
        .background {
            BackgroundAnimation(backgroundColor: Color(.gray).opacity(0.1), foregroundColor: .blue, logoOffset: CGSize(width: 300, height: 200))
        }
        .navigationTitle("Export Recipes")
        
        
    }
}

#Preview {
    ExportView(recipesManager: RecipesManager())
}
