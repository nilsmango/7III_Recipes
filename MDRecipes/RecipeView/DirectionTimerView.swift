//
//  DirectionTimerView.swift
//  MDRecipes
//
//  Created by Simon Lang on 01.04.23.
//

import SwiftUI

import SwiftUI

struct DirectionTimerView: View {
    @ObservedObject var timerManager: TimerManager
    
    var direction: Direction
    
    @Binding var timer: DirectionTimer
    
    
    // Step done indicator.
    @State private var done = false
    
    
    var body: some View {
        HStack {
            if done {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
            VStack(alignment: .leading) {
                Text(direction.text)
//                                        .id(makeIndex(of: direction))
                    .strikethrough(done ? true : false)
                    .onTapGesture {
                            done.toggle()
                        
                    }

                    if done == false {
                        Button(action: {
                            timer.running.toggle()
                        }) {
                            Image(systemName: "timer")
                            if timer.running {
                                Text(timer.targetDate, style: .timer)
                                    .monospacedDigit()
                            } else {
                                Text("\(Int(direction.timerInMinutes)) min")
                            }
                        }
                        .foregroundColor(.white)
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    }
                }
        }
        .padding(.vertical)
    }
}

struct DirectionTimerView_Previews: PreviewProvider {
    static var previews: some View {
        DirectionTimerView(timerManager: TimerManager(), direction: Direction(step: 2, text: "2. Drink it all up for 2 minutes", hasTimer: true, timerInMinutes: 2), timer: .constant(DirectionTimer(targetDate: Date(timeIntervalSinceNow: 2344), timerInMinutes: 10, step: 2, running: true, id: UUID())))
    }
}

