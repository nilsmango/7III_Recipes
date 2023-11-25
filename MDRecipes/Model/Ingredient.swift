//
//  Ingredient.swift
//  MDRecipes
//
//  Created by Simon Lang on 31.03.23.
//

import Foundation

struct Ingredient: Identifiable, Codable {
    
    var text: String
    var selected: Bool = false
    
    let id: UUID
    
    init(text: String, id: UUID = UUID()) {
        self.text = text
        self.id = id
    }
  
}
