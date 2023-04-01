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
    @State private var selected = false
    
    var body: some View {
        HStack {
            
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(selected ? .blue : .primary)
            
            Text(Parser.stringMaker(of: ingredientString, selectedServings: chosenServings, recipeServings: recipeServings))
        }
        .onTapGesture {
            selected.toggle()
        }
        
    }
    
}

struct IngredientView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientView(ingredientString: "1 egg", recipeServings: 4, chosenServings: 6)
    }
}
