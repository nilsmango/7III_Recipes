//
//  RecipeSegment.swift
//  MDRecipes
//
//  Created by Simon Lang on 07.04.23.
//

import Foundation

struct RecipeSegment: Identifiable, Codable {
    var part: RecipeParts
    var lines: [String]
    
    let id: UUID
    
    
    init(part: RecipeParts, lines: [String], id: UUID = UUID()) {
        self.part = part
        self.lines = lines
        self.id = id
    }
}
