//
//  IngredientView.swift
//  MDRecipes
//
//  Created by Simon Lang on 21.03.23.
//

import SwiftUI

struct IngredientView: View {
    var ingredient: String
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
                
            Text(stringMaker())
        }
        
    }
    
    private func stringMaker() -> String {
        
        let cleanIngredient = cleanUpIngredientString(string: ingredient)
        
        let numbersRange = cleanIngredient.rangeOfCharacter(from: .decimalDigits)
        
        if numbersRange != nil {
            // hier muss noch irgendwie nach zahlen und nicht zahlen getrennt werden hier schon oder später, damit auch 10kg funktioniert
            let input = cleanIngredient.components(separatedBy: .whitespaces).map { String($0) }
            
            // hier auch checken ob "one" oder "two" ist
            let preFirst = Double(input.first ?? "0.0")
            
            let first = ((preFirst ?? 1) * Double(chosenServings)) / Double(recipeServings)
            let rest = input.dropFirst()
            let output = rest.joined(separator: " ")
            let stringOfFirst: String
    //        if first == 1 {
    //            unit = ingredient.unit.singular
    //            if unit == "" {
    //                name = ingredient.nameSingular
    //            }
    //        }
    //        if unit == "part" || unit == "pinch" || unit == "pinch of" || unit == "pinches of" || unit == "parts of" || unit == "part of" || unit == "piece of" || unit == "pieces of" {
    //        This is pretty stupid, right?
    //            name = ingredient.nameSingular
    //        }
            
            if floor(first) == first {
                stringOfFirst = String(Int(first))
            } else {
                stringOfFirst = String((first*10).rounded()/10)
            }
            let second = " " + output
            
            return stringOfFirst + second
        } else {
            return ingredient
        
        }
    }
}

struct IngredientView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientView(ingredient: "200g carrot", recipeServings: 4, chosenServings: 2, selected: false)
    }
}
