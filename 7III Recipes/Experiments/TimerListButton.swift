//
//  TimerViewTest.swift
//  MDRecipes
//
//  Created by Simon Lang on 22.03.23.
//

import SwiftUI

struct TimerListButton: View {
    // in-App notification
    @StateObject var delegate = NotificationDelegate()
    private let notificationCenter = UNUserNotificationCenter.current()
    // timerTime in minutes
    var timerTime: Double
    var step: String
    var targetDate: Date
    
    @Binding var timerRunning: Bool
    
    private func timerTrigger() {
        if !timerRunning {
            
            let remainingTime = targetDate.timeIntervalSinceNow
            
            let content = UNMutableNotificationContent()
            content.title = "Timer Step \(step)"
            content.subtitle = "Step \(step) timer has reached 0!"
            content.sound = UNNotificationSound.default
            
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            let request = UNNotificationRequest(identifier: "timerFinished", content: content, trigger: trigger)
            
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error: \(error)")
                }
            }
            timerRunning = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + remainingTime) {
                timerRunning = false
            }
            
        } else {
            timerRunning = false
            notificationCenter.removePendingNotificationRequests(withIdentifiers: ["timerFinished"])
            
        }
    }
    
    var body: some View {
        HStack {
            Button(action: {
                timerTrigger()
            }) {
                
                    Image(systemName: "timer")
                    if timerRunning {
                        Text(targetDate, style: .timer)
                            .monospacedDigit()
                    } else {
                        if timerTime >= 60 {
                            if Int(timerTime) % 60 == 0 {
                                Text("\(Int(timerTime/60)) h")
                            } else {
                                Text("\(Int(timerTime/60)) h \(Int(timerTime) % 60) min")
                            }
                            
                        } else if timerTime >= 1 {
                            Text("\(Int(timerTime)) min")
                        } else {
                            Text("\(Int(timerTime * 60)) s")
                        }
                        
                    }
                    
                }
            }
            .foregroundColor(.white)
            .buttonStyle(.borderedProminent)
            
            
        
        .onAppear() {
            notificationCenter.requestAuthorization(options: [.alert, .sound]) { success, error in
                if success {
//                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            notificationCenter.delegate = delegate
        }
        
    }
    
}

struct TimerListButton_Previews: PreviewProvider {
    static var previews: some View {
        TimerListButton(timerTime: 70, step: "5", targetDate: Date.init(timeIntervalSinceNow: 70 * 60), timerRunning: .constant(false))
    }
}
