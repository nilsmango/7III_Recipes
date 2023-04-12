//
//  Recipe.swift
//  MDRecipes
//
//  Created by Simon Lang on 24.03.23.
//

import Foundation
import UIKit

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
    var images: [RecipeImage]
    
    var language: RecipeLanguage
    
    var date: Date
    var updated: Date

    let id: UUID

    init(title: String, source: String, categories: [String], tags: [String], rating: String, prepTime: String, cookTime: String, additionalTime: String, totalTime: String, servings: Int, timesCooked: Int, ingredients: [Ingredient], directions: [Direction], nutrition: String, notes: String, images: [RecipeImage], date: Date, updated: Date, language: RecipeLanguage, id: UUID = UUID()) {
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
        self.date = date
        self.updated = updated
        self.language = language
        self.id = id
    }

}

extension Recipe {
    static var sampleData: [Recipe] {
        [ Recipe(title: "Essen", source: "http://nilsmango.ch", categories: ["Dinner", "Rice", "Chicken"], tags: ["#meat", "#quick"], rating: "4/5", prepTime: "10 min", cookTime: "20 min", additionalTime: "2 min", totalTime: "32 min", servings: 4, timesCooked: 0, ingredients: [Ingredient(text: "1 chicken breast"), Ingredient(text: "2 cups of water"), Ingredient(text: "20 g cheddar")], directions: [Direction(step: 1, text: "1. Take 5 minutes to breath\nThen relax", hasTimer: true, timerInMinutes: 5), Direction(step: 2, text: "2. Cook it all up", hasTimer: false, timerInMinutes: 0), Direction(step: 3, text: "3. Let it cool before you eat", hasTimer: false, timerInMinutes: 0)], nutrition: "100% love", notes: "Don't cook this!", images: [], date: Date(timeIntervalSince1970: 12323), updated: Date(timeIntervalSinceNow: -2342), language: .english)
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
        
        var ingredients: [Ingredient] = []
        var directions: [Direction] = []
        var nutrition: String = ""
        var notes: String = ""
        
        var oldImages: [RecipeImage] = []
        
        var dataImages: [RecipeImageData] = []
        
        
        var date: Date = Date.now
        var updated: Date = Date.now
        
        var language: RecipeLanguage = .english
        
    }
    // for when we edit a recipe
    var data: Data {
        return Data(title: title, source: source, categories: categories, tags: tags, rating: rating, prepTime: prepTime, cookTime: cookTime, additionalTime: additionalTime, totalTime: totalTime, servings: servings, timesCooked: timesCooked, ingredients: ingredients, directions: directions, nutrition: nutrition, notes: notes, oldImages: images, dataImages: images.map( { RecipeImageData(image: UIImage(contentsOfFile: $0.imagePath) ?? UIImage(systemName: "photo")!, caption: $0.caption, isOldImage: true, id: $0.id)  }), date: date, updated: updated, language: language)
    }
    
   
}
