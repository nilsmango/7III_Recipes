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
    
    
    var body: some Scene {
        WindowGroup {
            RecipesListView(fileManager: fileManager)
        }
    }
}
