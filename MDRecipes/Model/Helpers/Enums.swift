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
    case remove, title, rating, servings, prepTime, cookTime, additionalTime, totalTime, date, ingredients, directions, nutrition, notes, categories, tags,  source, unknown
    var id: Self { self }
}



enum TimerStatus: String, CaseIterable, Identifiable, Codable {
    case running, alarm, stopped
    var id: Self { self }
}
