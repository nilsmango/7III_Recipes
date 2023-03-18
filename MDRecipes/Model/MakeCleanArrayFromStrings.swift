//
//  MakeCleanArrayFromStrings.swift
//  MDRecipes
//
//  Created by Simon Lang on 18.03.23.
//

import Foundation

func makeCleanArray(from: String) -> [String] {
    let stringArray = from.components(separatedBy: " ")
    let cleanArray = stringArray.filter( { $0 != "" })
    return cleanArray
}
