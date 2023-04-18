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
    @StateObject private var delegate = NotificationDelegate()
        
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            HomeView(fileManager: fileManager, delegate: delegate)
                .onAppear {
                    fileManager.loadMarkdownFiles()
                    // loading all the timers afresh
                    fileManager.loadTimersAndTrashFromDisk()
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
