//
//  Enums.swift
//  MDRecipes
//
//  Created by Simon Lang on 20.03.23.
//

import Foundation


enum Sorting: String, CaseIterable, Identifiable, Codable {
    case standard, name, time, rating, cooked
    var id: Self { self }
}

enum RecipeLanguage: String, CaseIterable, Identifiable, Codable {
    case english, german
    var id: Self { self }
}

enum RecipeParts: String, CaseIterable, Identifiable, Codable {
    case title, source, categories, tags, rating, prepTime, cookTime, additionalTime, totalTime, servings, timesCooked, ingredients, directions, nutrition, notes, images, date, updated, unknown
    var id: Self { self }
}
