//
//  TimerViewTest.swift
//  MDRecipes
//
//  Created by Simon Lang on 22.03.23.
//

import SwiftUI

struct TimerViewTop: View {
    // timerTime in minutes
    var timerTime: Double
    var step: String
    private var timerDate: Date {
        Date.now.addingTimeInterval(TimeInterval(timerTime * 60))
    }
    @Binding var timerRunning: Bool
    
    var body: some View {
            
                    if timerRunning {
                        
                            HStack {
                                
                                Image(systemName: "timer")
                                Text(timerDate, style: .timer)
                                        .monospacedDigit()
                                }
                            .foregroundColor(.white)
                            
                            .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                            .background(.blue)
                            .clipShape(Capsule())
                        }
                   
            
                
                
            
    }
    
    
    
}

struct TimerViewTop_Previews: PreviewProvider {
    static var previews: some View {
        TimerViewTop(timerTime: 70, step: "5", timerRunning: .constant(true))
    }
}
