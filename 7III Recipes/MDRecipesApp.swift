//
//  MDRecipesApp.swift
//  MDRecipes
//
//  Created by Simon Lang on 16.03.23.
//

import SwiftUI

@main
struct MDRecipesApp: App {
    @State private var importedContent: String?
    
    var body: some Scene {
        WindowGroup {
            if importedContent == nil {
                StartView()
                    .onOpenURL { url in
                        do {
                            // Read content from the file at the URL
                            let data = try Data(contentsOf: url)
                            if let decodedString = String(data: data, encoding: .utf8) {
                                importedContent = decodedString
                            }
                        }
                                    catch {
                                            print("Error opening URL: \(error.localizedDescription)")
                                        }
                                    }
            } else {
                Text(importedContent ?? "")
                    
            }
                
            
            
        }
        
    }
}
