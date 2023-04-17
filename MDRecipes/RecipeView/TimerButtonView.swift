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
    
    @State private var currentDate = Date.now
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var numberOfShakes: CGFloat = 0
    
    var body: some View {
        Button(action: {
            fileManager.toggleTimer(timer: dirTimer)
            currentDate = Date.now
        }) {
            Image(systemName: "timer")
            if dirTimer.running == .running {
                if dirTimer.stepName != "" {
                    
                }
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
    }
}

struct TimerButtonView_Previews: PreviewProvider {
    static var previews: some View {
        TimerButtonView(fileManager: RecipesManager(), dirTimer: DirectionTimer(targetDate: Date(timeIntervalSinceNow: 27), timerInMinutes: 10, recipeTitle: "Misty Eye", step: 2, running: .running, id: UUID()))
    }
}
