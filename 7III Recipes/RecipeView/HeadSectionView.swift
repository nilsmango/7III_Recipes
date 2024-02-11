//
//  HeadSectionView.swift
//  MDRecipes
//
//  Created by Simon Lang on 30.03.23.
//

import SwiftUI

struct HeadSectionView: View {
    var recipe: Recipe
    
    @ObservedObject var fileManager: RecipesManager
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !recipe.categories.isEmpty {
                HStack {
                    Image(systemName: "menucard")
                    Text(recipe.categories.prefix(2).joined(separator: ", "))
                    
                    
                }
                
            }
            HStack {
                Text("Rating:")
                RecipeRatingEditView(recipe: recipe, fileManager: fileManager)
            }
            
            if recipe.prepTime != "" {
                HStack {
                    Text("Prep time:")
                    Text(recipe.prepTime)
                }
            }
            
            if recipe.cookTime != "" {
                HStack {
                    Text("Cook time:")
                    Text(recipe.cookTime)
                }
            }
            
            if recipe.additionalTime != "" {
                HStack {
                    Text("Additional time:")
                    Text(recipe.additionalTime)
                }
            }
            
            if recipe.totalTime != "" {
                HStack {
                    Text("Total time:")
                    Text(recipe.totalTime)
                }
            }
            
        }
        .padding(.vertical, 3)
    }
}

struct HeadSectionView_Previews: PreviewProvider {
    static var previews: some View {
        HeadSectionView(recipe: Recipe.sampleData[0], fileManager: RecipesManager())
    }
}
