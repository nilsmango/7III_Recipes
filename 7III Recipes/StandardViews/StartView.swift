//
//  StartView.swift
//  7III Recipes
//
//  Created by Simon Lang on 03.12.23.
//

import SwiftUI

struct StartView: View {
    @ObservedObject var recipesManager: RecipesManager
        
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var loading = true
    
    @State private var showSplash = true
    
    var body: some View {
        if showSplash {
            SplashViewAnimation(loading: $loading, showSplash: $showSplash)
                .onAppear {
                    DispatchQueue.main.async {
                        // 1. loading all the timers and trash from disk
                        recipesManager.loadTimersAndTrashFromDisk()
                        // 2. loading the recipes from markdown
                        recipesManager.loadMarkdownFiles { result in
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
            HomeView(recipesManager: recipesManager)
                .onChange(of: scenePhase) { phase in
                    if phase == .inactive {
                        // saving our timer status to disk
                        recipesManager.saveTimersAndTrashToDisk()
                    }
                }
        }
        
            
            
    }
}

#Preview {
    StartView(recipesManager: RecipesManager())
}
