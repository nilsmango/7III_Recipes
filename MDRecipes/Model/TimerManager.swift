//
//  TimerManager.swift
//  MDRecipes
//
//  Created by Simon Lang on 28.03.23.
//

import Foundation
import SwiftUI

class TimerManager: ObservableObject {
    
    @Published var timers = [DirectionTimer]()
    
    func loadTimers(of recipe: Recipe) {
        for direction in recipe.directions {
            if direction.hasTimer {
                self.timers.append(DirectionTimer(targetDate: Date.now, step: direction.step, running: false, backgroundColor: .blue, fontColor: .white))
            }
        }
    }
    
}
