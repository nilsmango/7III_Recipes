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

enum Language: Codable {
    case english, german
}
