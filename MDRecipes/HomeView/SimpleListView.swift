//
//  SimpleListView.swift
//  MDRecipes
//
//  Created by Simon Lang on 13.04.23.
//

import SwiftUI

struct SimpleListView: View {
    @ObservedObject var recipesManager: RecipesManager
    
    var body: some View {

        VStack {
            
                ForEach(recipesManager.recipes) { recipe in
                    NavigationLink(destination: RecipeView(fileManager: recipesManager, recipe: recipe)) {
                        Text(recipe.title)
                    }
                    
                }
            }
        }
    
}

struct SimpleListView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleListView(recipesManager: RecipesManager())
    }
}
