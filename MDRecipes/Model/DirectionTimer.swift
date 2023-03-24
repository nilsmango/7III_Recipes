//
//  DirectionTimer.swift
//  MDRecipes
//
//  Created by Simon Lang on 24.03.23.
//

import Foundation
import SwiftUI

struct DirectionTimer: Identifiable {
    var targetDate: Date
    var step: Int
    var running: Bool
    var backgroundColor: UIColor
    var fontColor: UIColor
    
    var id: Int {
        step
    }
}
