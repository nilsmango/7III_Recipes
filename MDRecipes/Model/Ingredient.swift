//
//  Ingredient.swift
//  MDRecipes
//
//  Created by Simon Lang on 31.03.23.
//

import Foundation

import Foundation

struct Ingredient: Identifiable, Codable {
    var text: String
    
    let id: UUID
    
    init(text: String, id: UUID = UUID()) {
        self.text = text
        self.id = id
    }
  
}
