//
//  MDRecipesApp.swift
//  MDRecipes
//
//  Created by Simon Lang on 16.03.23.
//

import SwiftUI

@main
struct MDRecipesApp: App {
    @StateObject private var fileManager = RecipesManager()
        
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            HomeView(fileManager: fileManager)
                .onAppear {
                    // 1. loading all the timers and trash from disk
                    fileManager.loadTimersAndTrashFromDisk()
                    // 2. loading the recipes from markdown
                    fileManager.loadMarkdownFiles()
                }
                .onChange(of: scenePhase) { phase in
                    if phase == .inactive {
                        // saving our timer status to disk
                        fileManager.saveTimersAndTrashToDisk()
                    }
                }
        }
    }
}
