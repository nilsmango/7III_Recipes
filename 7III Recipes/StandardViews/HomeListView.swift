//
//  HomeListView.swift
//  7III Recipes
//
//  Created by Simon Lang on 01.03.2024.
//

import SwiftUI

struct HomeListView: View {
    @ObservedObject var recipesManager: RecipesManager
    
    var searchText: String
    
    var body: some View {
        List {
            ForEach(recipesManager.categories, id: \.self) { category in
                if !recipesManager.filterTheRecipes(string: searchText, ingredients: [], categories: [category], tags: []).isEmpty {
                    Section {
                        ForEach(recipesManager.filterTheRecipes(string: searchText, ingredients: [], categories: [category], tags: [])) { recipe in
                            NavigationLink(value: recipe) {
                                ListItemView(recipe: recipe)
                            }
                        }
                    } header: {
                        Text(category)
                            .font(.title3)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                    }
                }
            }
        }
        .navigationDestination(for: Recipe.self) { recipe in
            RecipeView(recipesManager: recipesManager, recipe: recipe)
        }
    }
}

#Preview {
    HomeListView(recipesManager: RecipesManager(), searchText: "Searching")
}
