//
//  DirectionTimer.swift
//  MDRecipes
//
//  Created by Simon Lang on 24.03.23.
//

import Foundation
import SwiftUI

/// a direction timer struct
struct DirectionTimer: Identifiable, Codable {
    var targetDate: Date
    var timerInMinutes: Double
    var recipeTitle: String
    var step: Int
    var running: Bool
    let id: UUID

}
