//
//  FloatingTimerView.swift
//  MDRecipes
//
//  Created by Simon Lang on 24.03.23.
//

import SwiftUI

struct FloatingTimerView: View {
    var targetDate: Date
    var step: Int
    var running: Bool
    
    var body: some View {
        if running {
           
                    HStack {
                        Image(systemName: "timer")
                        Text("Step \(step)")
                        Text(targetDate, style: .timer)
                            .monospacedDigit()
                    }
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                        .background(.blue)
                        .clipShape(Capsule())
                
            }
    }
}

struct FloatingTimerView_Previews: PreviewProvider {
    static var previews: some View {
        FloatingTimerView(targetDate: Date.now.addingTimeInterval(4), step: 4, running: true)
    }
}
