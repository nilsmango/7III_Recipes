//
//  Ingredient.swift
//  MDRecipes
//
//  Created by Simon Lang on 24.03.23.
//

import Foundation

struct Ingredient: Identifiable, Codable {
    var name: String
    let id: UUID
    
    init(name: String, id: UUID = UUID()) {
        self.name = name
        self.id = id
    }
    
}
