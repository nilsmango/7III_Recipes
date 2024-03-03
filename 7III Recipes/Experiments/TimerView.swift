//
//  TimerView.swift
//  MDRecipes
//
//  Created by Simon Lang on 22.03.23.
//

import SwiftUI

struct TimerView: View {
    // timerTime in minutes
    var timerTime: Double
    @State private var remainingTime = 60
    @State private var timerRunning = false
    let notificationCenter = UNUserNotificationCenter.current()
    
    private func timerTrigger() {
        if !timerRunning {
            remainingTime = Int(timerTime * 60)
            
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
                    Label(timerRunning ? "Time Remaining: \(remainingTime) seconds" : "Start \(Int(timerTime)) min Timer", systemImage: "timer")
                        .monospacedDigit()
                }.foregroundColor(.white)
                .buttonStyle(.borderedProminent)
                .onAppear() {
                    notificationCenter.requestAuthorization(options: [.alert, .sound]) { success, error in
                        if success {
//                            print("All set!")
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }
                
            
    }
    
    
    
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(timerTime: 120)
    }
}
