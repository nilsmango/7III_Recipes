//
//  DateToDateFormatted.swift
//  MDRecipes
//
//  Created by Simon Lang on 17.04.23.
//

import Foundation

/// Time between dates formatted into a string of days

func dateToDateFormatted(from: Date, to: Date) -> String {
    let timeComponent = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: from, to: to)
    
    let days = String(timeComponent.day!)
    var hours = String(format: "%02d", arguments: [timeComponent.hour!])
    var minutes = String(format: "%02d", arguments: [timeComponent.minute!])
    
    if days == "0" && hours.count == 2 && hours.hasPrefix("0") {
        hours.removeFirst()
    }
    
    if hours == "0" && days == "0" && minutes.count == 2 && minutes.hasPrefix("0") {
        minutes.removeFirst()
    }
    
    let seconds = String(format: "%02d", arguments: [timeComponent.second!])
    
    if hours == "0" && days == "0" {
        let time = minutes + ":" + seconds
        return time
    } else if days == "0" {
        let time = hours + ":" + minutes + ":" + seconds
        return time
    } else {
        let formatted = days + " " + hours + ":" + minutes + ":" + seconds
        return formatted
    }
}
