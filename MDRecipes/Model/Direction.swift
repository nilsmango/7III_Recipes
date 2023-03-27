//
//  Direction.swift
//  MDRecipes
//
//  Created by Simon Lang on 24.03.23.
//

import Foundation

struct Direction: Identifiable, Codable {
    var step: Int
    var text: String
    var hasTimer: Bool
    var timerInMinutes: Double
    
    var id: Int {
        step
    }
}
