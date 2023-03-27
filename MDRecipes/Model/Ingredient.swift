//
//  Ingredient.swift
//  MDRecipes
//
//  Created by Simon Lang on 24.03.23.
//

import Foundation

struct Ingredient: Identifiable, Codable {
    var amount: Int
    var unit: String
    var name: String
    let id: UUID
    
    init(amount: Int, unit: String, name: String, id: UUID = UUID()) {
        self.amount = amount
        self.unit = unit
        self.name = name
        self.id = id
    }
    
}
