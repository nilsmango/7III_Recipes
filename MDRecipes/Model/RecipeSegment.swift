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
    var titleLineWeDontShow: String
    
    let id: UUID
    
    
    init(part: RecipeParts, lines: [String], titleLineWeDontShow: String = "", id: UUID = UUID()) {
        self.part = part
        self.lines = lines
        self.titleLineWeDontShow = titleLineWeDontShow
        self.id = id
    }
}
