//
//  TimerManager.swift
//  MDRecipes
//
//  Created by Simon Lang on 28.03.23.
//

import Foundation
import SwiftUI

/// this timer manager gives us the ability to see all the timer of all the recipes everywhere in the app.
class TimerManager: ObservableObject {
    
    @Published var timers = [DirectionTimer]()
    
    func loadTimers(for directions: [Direction]) {
        for direction in directions {
            if let index = timers.firstIndex(where: { $0.id == direction.id }) {
                timers.remove(at: index)
            }
            if direction.hasTimer {
                timers.append(DirectionTimer(targetDate: Date.now, timerInMinutes: direction.timerInMinutes, step: direction.step, running: false, id: direction.id))
            }
        }
    }
    
    // Idea how to keep the timers up when view gets destroyed
    
    private static var documentsFolder: URL {
        let appIdentifier = "group.qrcoder.codes"
        return FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appIdentifier)!
    }
    private static var fileURL: URL {
        return documentsFolder.appendingPathComponent("recipes.data")
    }
    
    
    
    func saveTimersToDisk() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let timers = self?.timers else { fatalError("Self out of scope!") }
            guard let data = try? JSONEncoder().encode(timers) else { fatalError("Error encoding data") }
            
            do {
                let outFile = Self.fileURL
                try data.write(to: outFile)
    //            WidgetCenter.shared.reloadAllTimelines()
                
            } catch {
                fatalError("Couldn't write to file")
            }
        }
        }
        
    func loadTimersFromDisk() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let data = try? Data(contentsOf: Self.fileURL) else {
                return
                
            }
            guard let jsonTimers = try? JSONDecoder().decode([DirectionTimer].self, from: data) else {
                fatalError("Couldn't decode saved codes data")
            }
            DispatchQueue.main.async {
                self?.timers = jsonTimers
                
            }
        }
        }
}
