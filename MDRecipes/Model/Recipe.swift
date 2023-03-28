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
    
    var ingredients: [String]
    var directions: [Direction]
    var nutrition: String
    var notes: String
    var images: String
    
    var language: Language

    let id: UUID

    init(title: String, source: String, categories: [String], tags: [String], rating: String, prepTime: String, cookTime: String, additionalTime: String, totalTime: String, servings: Int, timesCooked: Int, ingredients: [String], directions: [Direction], nutrition: String, notes: String, images: String, language: Language, id: UUID = UUID()) {
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

extension Recipe {
    static var sampleData: [Recipe] {
        [ Recipe(title: "Essen", source: "http://nilsmango.ch", categories: ["Dinner", "Rice", "Chicken"], tags: ["#meat", "#quick"], rating: "4/5", prepTime: "10 min", cookTime: "20 min", additionalTime: "2 min", totalTime: "32 min", servings: 4, timesCooked: 0, ingredients: ["1 chicken breast", "2 cups of water", "20 g cheddar"], directions: [Direction(step: 1, text: "1. Take 5 minutes to breath\nThen relax", hasTimer: true, timerInMinutes: 5), Direction(step: 2, text: "2. Cook it all up", hasTimer: false, timerInMinutes: 0), Direction(step: 3, text: "3. Let it cool before you eat", hasTimer: false, timerInMinutes: 0)], nutrition: "100% love", notes: "Don't cook this!", images: "", language: .english)
        ]
    }
}



extension Recipe {
    struct Data {
        var title: String = ""
        var source: String = ""
        var categories: [String] = []
        var tags: [String] = []
        var rating: String = ""
        var prepTime: String = ""
        var cookTime: String = ""
        var additionalTime: String = ""
        var totalTime: String = ""
        var servings: Int = 4
        var timesCooked: Int = 0
        
        var ingredients: [String] = []
        var directions: [Direction] = []
        var nutrition: String = ""
        var notes: String = ""
        var images: String = ""
        
        var language: Language = .english
        
    }
    
    var data: Data {
        return Data(title: title, source: source, categories: categories, tags: tags, rating: rating, prepTime: prepTime, cookTime: cookTime, additionalTime: additionalTime, totalTime: totalTime, servings: servings, timesCooked: timesCooked, ingredients: ingredients, directions: directions, nutrition: nutrition, notes: notes, images: images, language: language)
    }
    
    mutating func update(from data: Data) {
        title = data.title
        source = data.source
        categories = data.categories
        tags = data.tags
        rating = data.rating
        prepTime = data.prepTime
        cookTime = data.cookTime
        additionalTime = data.additionalTime
        totalTime = data.totalTime
        servings = data.servings
        timesCooked = data.timesCooked
        ingredients = data.ingredients
        directions = data.directions
        nutrition = data.nutrition
        notes = data.notes
        images = data.images
        language = data.language
    }
}
