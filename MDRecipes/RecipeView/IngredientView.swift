//
//  IngredientView.swift
//  MDRecipes
//
//  Created by Simon Lang on 21.03.23.
//

import SwiftUI

struct IngredientView: View {
    var ingredientString: String
    var recipeServings: Int
    var chosenServings: Int
    var selected: Bool
    
    var body: some View {
        HStack {
            if selected {
                Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.blue)
            } else {
                Image(systemName: "circle")
            }
            Text(Parser.stringMaker(of: ingredientString, selectedServings: chosenServings, recipeServings: recipeServings))
        }
        
    }
    
}

struct IngredientView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientView(ingredientString: "1 egg", recipeServings: 4, chosenServings: 6, selected: true)
    }
}
