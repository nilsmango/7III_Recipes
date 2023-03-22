//
//  TimerView.swift
//  MDRecipes
//
//  Created by Simon Lang on 22.03.23.
//

import SwiftUI

struct TimerView: View {
    // timerTime in minutes
    var timerTime: Int
    @State private var remainingTime = 60
    @State private var timerRunning = false
    let notificationCenter = UNUserNotificationCenter.current()
    
    private func timerTrigger() {
        if !timerRunning {
            remainingTime = timerTime * 60
            
            timerRunning = true
            let currentDate = Date()
            let targetDate = currentDate.addingTimeInterval(TimeInterval(remainingTime))
            
            let content = UNMutableNotificationContent()
            content.title = "Timer Finished"
            content.sound = UNNotificationSound.default
            
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            let request = UNNotificationRequest(identifier: "timerFinished", content: content, trigger: trigger)
            
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error: \(error)")
                }
            }
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if timerRunning == true && remainingTime > 0 {
                    remainingTime -= 1
                } else if timerRunning == false || remainingTime <= 0 {
                    timer.invalidate()
                    timerRunning = false
                }
            }
            
        } else {
            timerRunning = false
            notificationCenter.removeDeliveredNotifications(withIdentifiers: ["timerFinished"])
            
        }
    }
    
    var body: some View {
            Button(action: {
                timerTrigger()
                }) {
                    Label(timerRunning ? "Time Remaining: \(remainingTime) seconds" : "Start \(timerTime) minute timer", systemImage: "timer")
                        .monospacedDigit()
            }
                
            
    }
    
    
    
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(timerTime: 120)
    }
}
