//
//  RecipeImage.swift
//  MDRecipes
//
//  Created by Simon Lang on 11.04.23.
//

import Foundation

struct RecipeImage: Identifiable, Codable, Hashable {
    var imagePath: String
    var caption: String
    
    let id: UUID
    
    init(imagePath: String, caption: String, id: UUID = UUID()) {
        self.imagePath = imagePath
        self.caption = caption
        self.id = id
    }
}


