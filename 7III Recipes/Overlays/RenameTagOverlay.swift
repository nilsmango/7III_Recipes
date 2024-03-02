//
//  RenameTagOverlay.swift
//  7III Recipes
//
//  Created by Simon Lang on 02.03.2024.
//

import SwiftUI

struct RenameTagOverlay: View {
    @ObservedObject var recipesManager: RecipesManager
    
    var body: some View {
        ZStack {
            
            if recipesManager.tagAlert.showRenameAlert {
                RenameTagVStack(recipesManager: recipesManager)
            }
            
            AlertOverlay(showAlert: $recipesManager.tagAlert.showDoneAlert, text: recipesManager.tagAlert.doneAlertText, symbolPositive: true)
        }
    }
}

#Preview {
    RenameTagOverlay(recipesManager: RecipesManager())
}
