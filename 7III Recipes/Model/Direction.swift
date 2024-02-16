//
//  Direction.swift
//  MDRecipes
//
//  Created by Simon Lang on 24.03.23.
//

import Foundation

struct Direction: Identifiable, Codable, Hashable {
    var step: Int
    var text: String
    var hasTimer: Bool
    var timerInMinutes: Double
    var done: Bool = false
    
    let id: UUID
    
    init(step: Int, text: String, hasTimer: Bool, timerInMinutes: Double, id: UUID = UUID()) {
        self.step = step
        self.text = text
        self.hasTimer = hasTimer
        self.timerInMinutes = timerInMinutes
        self.id = id
    }
}
