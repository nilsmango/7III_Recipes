//
//  RecipeRatingView.swift
//  MDRecipes
//
//  Created by Simon Lang on 30.03.23.
//

import SwiftUI

struct RecipeRatingView: View {
    @Binding var rating: Int
    let recipe: Recipe
    @ObservedObject var fileManager: MarkdownFileManager

        var body: some View {
            ForEach(1...5, id: \.self) { selectedRating in
                let fill = rating >= selectedRating
                Image(systemName: fill ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .onTapGesture {
                        rating = selectedRating
                        fileManager.updateRating(of: recipe, to: rating)
                    }
                    
            }
        }
    }

struct RecipeRatingView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            RecipeRatingView(rating: .constant(3), recipe: Recipe.sampleData[0], fileManager: MarkdownFileManager())
        }
        
    }
}
