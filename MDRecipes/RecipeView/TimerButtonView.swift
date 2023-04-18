//
//  TimerButtonView.swift
//  MDRecipes
//
//  Created by Simon Lang on 17.04.23.
//

import SwiftUI

struct TimerButtonView: View {
    @ObservedObject var fileManager: RecipesManager
    
    var dirTimer: DirectionTimer
    
    @State private var currentDate = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var numberOfShakes: CGFloat = 0
    
    // in-App notification
    @ObservedObject var delegate: NotificationDelegate
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    var body: some View {
        Button(action: {
            fileManager.toggleTimer(timer: dirTimer)
            currentDate = Date()
            
            if dirTimer.running == .stopped {
                // add a notification for this timer
                let content = UNMutableNotificationContent()
                content.title = "Timer from \(dirTimer.recipeTitle)"
                content.subtitle = (dirTimer.stepName != "" ? dirTimer.stepName : "Step \(dirTimer.step)") + " has reached 0!"
                content.sound = UNNotificationSound.default
                
                let targetDate = Date(timeIntervalSinceNow: TimeInterval(dirTimer.timerInMinutes * 60))
                let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                
                let request = UNNotificationRequest(identifier: dirTimer.recipeTitle + String(dirTimer.step), content: content, trigger: trigger)
                
                print(request)
                
                notificationCenter.add(request) { error in
                    if let error = error {
                        print("Error: \(error)")
                    }
                }
            } else {
                // remove notification for this timer
                print("removing Notification \(dirTimer.recipeTitle + String(dirTimer.step))" )
                notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(dirTimer.recipeTitle + String(dirTimer.step))"])
                
            }
           
        }) {
            Image(systemName: "timer")
            if dirTimer.running == .running {
                Text((dirTimer.stepName != "" ? dirTimer.stepName : "Step " + String(dirTimer.step)) + ": "  + dateToDateFormatted(from: currentDate, to: dirTimer.targetDate))
                    .monospacedDigit()
                    .onAppear {
                        if currentDate >= dirTimer.targetDate {
                            fileManager.toggleTimer(timer: dirTimer)
                        }
                    }
                    .onReceive(timer) { input in
                        currentDate = input
                        if currentDate >= dirTimer.targetDate {
                            fileManager.alarm(for: dirTimer)
                            withAnimation(.linear(duration: 5)) {
                                numberOfShakes = 40
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                numberOfShakes = 0
                            }
                        }
                    }
                    
            } else if dirTimer.running == .stopped {
                if dirTimer.timerInMinutes > 0.99 {
                    Text("\(Int(dirTimer.timerInMinutes)) min")
                } else {
                    Text("\(Int(dirTimer.timerInMinutes * 60)) s")
                }
                
            } else {
                Text((dirTimer.stepName != "" ? dirTimer.stepName : "Step " + String(dirTimer.step)) + ": 0:00")
                    .monospacedDigit()
            }
        }
        .foregroundColor(.white)
        .buttonStyle(.borderedProminent)
        .tint(dirTimer.running == .alarm ? .red : .blue)
        .modifier(ShakeEffect(shakeNumber: numberOfShakes))
        .onAppear {
            notificationCenter.requestAuthorization(options: [.alert, .sound]) { success, error in
                        if success {
//                            print("All set!")
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                    notificationCenter.delegate = delegate
        }
    }
}

struct TimerButtonView_Previews: PreviewProvider {
    static var previews: some View {
        TimerButtonView(fileManager: RecipesManager(), dirTimer: DirectionTimer(targetDate: Date(timeIntervalSinceNow: 27), timerInMinutes: 10, recipeTitle: "Misty Eye", step: 2, running: .running, id: UUID()), delegate: NotificationDelegate())
    }
}
