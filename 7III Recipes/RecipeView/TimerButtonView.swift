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
    
    // Notifications
    private let notificationCenter = UNUserNotificationCenter.current()
    
    var body: some View {
        HStack {
            Button(action: {
                fileManager.toggleTimer(timer: dirTimer)
                currentDate = Date()
                
                if dirTimer.running == .stopped {
                    // add a notification for this timer
                    let content = UNMutableNotificationContent()
                    content.title = dirTimer.recipeTitle
                    content.body = "Time's up for: \(dirTimer.stepString)"

                    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Kitchen Timer Normal.caf"))
                    
                    let targetDate = Date(timeIntervalSinceNow: TimeInterval(dirTimer.timerInMinutes * 60))
                    let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                    
                    let request = UNNotificationRequest(identifier: dirTimer.recipeTitle + Constants.notificationSeparator + String(dirTimer.step), content: content, trigger: trigger)
                    
                    notificationCenter.add(request) { error in
                        if let error = error {
                            print("Error: \(error)")
                        }
                    }
                } else {
                    withAnimation(.linear(duration: 0.6)) {
                        numberOfShakes = 0
                    }
                    // remove notification for this timer
                    print("removing Notification \(dirTimer.recipeTitle + String(dirTimer.step))" )
                    notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(dirTimer.recipeTitle + String(dirTimer.step))"])
                }
            }) {
                Image(systemName: "timer")
                if dirTimer.running == .running {
                    Text("Step " + String(dirTimer.step) + ": "  + dateToDateFormatted(from: currentDate, to: dirTimer.targetDate))
                        .monospacedDigit()
                    
                        .onReceive(timer) { input in
                            currentDate = input
                            if currentDate >= dirTimer.targetDate {
                                fileManager.alarm(for: dirTimer)
                                withAnimation(.linear(duration: 4)) {
                                    numberOfShakes = 33
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
                    Text("Step " + String(dirTimer.step) + ": 0:00")
                        .monospacedDigit()
                }
            }
            .foregroundColor(.white)
            .buttonStyle(.borderedProminent)
            .tint(dirTimer.running == .alarm ? .red : .blue)
            .modifier(ShakeEffect(shakeNumber: numberOfShakes))
            
            if dirTimer.running == .stopped {
                Button(action: {
                    fileManager.timerStepper(timer: dirTimer, add: false)
                }) {
                    Image(systemName: "minus.circle")
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    fileManager.timerStepper(timer: dirTimer, add: true)
                }) {
                    Image(systemName: "plus.circle")
                }
                .buttonStyle(.bordered)
            }
        }
        .onAppear {
            notificationCenter.requestAuthorization(options: [.alert, .sound]) { success, error in
                if success {
                    // print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            notificationCenter.delegate = fileManager
        }
    }
}

#Preview {
    TimerButtonView(fileManager: RecipesManager(), dirTimer: DirectionTimer(targetDate: Date(timeIntervalSinceNow: 27), timerInMinutes: 10, recipeTitle: "Misty Eye", stepString: "Let her rip for 10 minutes", step: 2, running: .stopped, id: UUID()))
}
