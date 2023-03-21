//
//  HelperFunctions.swift
//  MDRecipes
//
//  Created by Simon Lang on 21.03.23.
//

import Foundation

/// cleaning up the ingredient string
func cleanUpIngredientString(string: String) -> String {
    
    var newString = string
    
    for index in newString.indices {
        if index < newString.index(before: newString.endIndex) {
            if newString[index].isNumber {
                if newString[newString.index(after: index)].isLetter {
                    newString.insert(" ", at: newString.index(after: index))
                }
            } else if newString[index].isLetter {
                if newString[newString.index(after: index)].isNumber {
                    newString.insert(" ", at: newString.index(after: index))
                }
            }
        }
    }
    
    return newString
}
