//
//  MDRecipesApp.swift
//  MDRecipes
//
//  Created by Simon Lang on 16.03.23.
//

import SwiftUI

@main
struct MDRecipesApp: App {
    @StateObject private var fileManager = MarkdownFileManager()
    
    @StateObject private var timerManager = TimerManager()
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            HomeView(fileManager: fileManager, timerManager: timerManager)
                .onAppear {
                    // loading all the timers into our timer manager
                    timerManager.loadTimersFromDisk()
                }
                .onChange(of: scenePhase) { phase in
                    if phase == .inactive {
                        // saving our timer status to disk
                        timerManager.saveTimersToDisk()
                    }
                }
        }
    }
}
