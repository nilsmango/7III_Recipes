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
                    // loading all the timers into our timer manager
                    fileManager.loadTimersFromDisk()
                }
                .onChange(of: scenePhase) { phase in
                    if phase == .inactive {
                        // saving our timer status to disk
                        fileManager.saveTimersToDisk()
                    }
                }
        }
    }
}
