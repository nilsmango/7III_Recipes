//
//  ListItemView.swift
//  MDRecipes
//
//  Created by Simon Lang on 17.03.23.
//

import SwiftUI

struct ListItemView: View {
    var recipe: Recipe
    
    private func findTimeOfRecipe(recipe: Recipe) -> String {
        switch true {
        case !recipe.totalTime.isEmpty:
            return recipe.totalTime
        case !recipe.cookTime.isEmpty:
            return recipe.cookTime
        case !recipe.prepTime.isEmpty:
            return recipe.prepTime
        case !recipe.additionalTime.isEmpty:
            return recipe.additionalTime
        default:
            return "-"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(recipe.title)
                .accessibilityLabel("Recipe name")
            HStack {
                let timeString = findTimeOfRecipe(recipe: recipe)
                Image(systemName: "clock")
                Text(timeString)
                
                Image(systemName: "star")
                if recipe.rating != "" {
                    Text(recipe.rating)
                } else {
                    Text("-")
                }
            }
            .font(.caption)
            
        }
        
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemView(recipe: Recipe.sampleData.first!)
    }
}
