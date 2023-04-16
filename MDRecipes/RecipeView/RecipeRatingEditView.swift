//
//  RecipeRatingView.swift
//  MDRecipes
//
//  Created by Simon Lang on 30.03.23.
//

import SwiftUI

struct RecipeRatingEditView: View {
    let recipe: Recipe
    
    var ratingInt: Int {
        Int(String(recipe.rating.first ?? Character("1")))!
    }
    
    @ObservedObject var fileManager: RecipesManager

        var body: some View {

                ForEach(1...5, id: \.self) { selectedRating in
                    let fill = ratingInt >= selectedRating
                    Image(systemName: fill ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            fileManager.updateRating(of: recipe, to: selectedRating)
                        }
                        
                }
                
            
            

        }
    }

struct RecipeRatingEditView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            RecipeRatingEditView(recipe: Recipe.sampleData[0], fileManager: RecipesManager())
        }
        
    }
}
