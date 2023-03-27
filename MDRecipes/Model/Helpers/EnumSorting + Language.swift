//
//  Enums.swift
//  MDRecipes
//
//  Created by Simon Lang on 20.03.23.
//

import Foundation


enum Sorting: String, CaseIterable, Identifiable, Codable {
    case manual, name, time, rating
    var id: Self { self }
}

enum Language: Codable {
    case english, german
}
