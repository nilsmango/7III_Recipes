//
//  Recipe.swift
//  MDRecipes
//
//  Created by Simon Lang on 24.03.23.
//

import Foundation

struct Recipe: Identifiable, Codable {
    var title: String
    var source: String
    var categories: [String]
    var tags: [String]
    var rating: String
    var prepTime: String
    var cookTime: String
    var additionalTime: String
    var totalTime: String
    var servings: Int
    var timesCooked: Int
    
    var ingredients: [Ingredient]
    var directions: [Direction]
    var nutrition: String
    var notes: String
    var images: String
    
    var language: Language

    let id: UUID

    init(title: String, source: String, categories: [String], tags: [String], rating: String, prepTime: String, cookTime: String, additionalTime: String, totalTime: String, servings: Int, timesCooked: Int, ingredients: [Ingredient], directions: [Direction], nutrition: String, notes: String, images: String, language: Language, id: UUID = UUID()) {
        self.title = title
        self.source = source
        self.categories = categories
        self.tags = tags
        self.rating = rating
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.additionalTime = additionalTime
        self.totalTime = totalTime
        self.servings = servings
        self.timesCooked = timesCooked
        self.ingredients = ingredients
        self.directions = directions
        self.notes = notes
        self.nutrition = nutrition
        self.images = images
        self.language = language
        self.id = id
    }

}
