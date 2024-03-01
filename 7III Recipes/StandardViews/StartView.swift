//
//  StartView.swift
//  7III Recipes
//
//  Created by Simon Lang on 03.12.23.
//

import SwiftUI

struct StartView: View {
    @ObservedObject var recipesManager: RecipesManager
            
    @State private var loading = true
    
    @State private var showSplash = true
    
    // edit view in home view
    @Binding var editViewPresented: Bool
    @Binding var newRecipeData: Recipe.Data
    @Binding var comingFromImportView: Bool
    
    var body: some View {
        if showSplash {
            SplashViewAnimation(loading: $loading, showSplash: $showSplash)
                .onAppear {
                    DispatchQueue.main.async {
                        // 1. loading all the timers and trash from disk
                        recipesManager.loadTimersAndTrashFromDisk()
                        // 2. loading the recipes from markdown
                        recipesManager.loadMarkdownFilesAndStart { result in
                            switch result {
                            case .success:
                                    loading = false
                            case .failure(let error):
                                print("Error loading files: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            
        } else {
            HomeView(recipesManager: recipesManager, editViewPresented: $editViewPresented, newRecipeData: $newRecipeData, comingFromImportView: $comingFromImportView)
                
        }
        
            
            
    }
}

#Preview {
    StartView(recipesManager: RecipesManager(), editViewPresented: .constant(false), newRecipeData: .constant(Recipe.sampleData.first!.data), comingFromImportView: .constant(false))
}
