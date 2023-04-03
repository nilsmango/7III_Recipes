//
//  ListItemView.swift
//  MDRecipes
//
//  Created by Simon Lang on 17.03.23.
//

import SwiftUI

struct ListItemView: View {
    var recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(recipe.title)
                .accessibilityLabel("Recipe name")
            HStack {
                Image(systemName: "clock")
                Text(recipe.totalTime)
                if recipe.rating != "" {
                    Image(systemName: "star")
                    Text(recipe.rating)
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
