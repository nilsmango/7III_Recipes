//
//  DirectionView.swift
//  MDRecipes
//
//  Created by Simon Lang on 27.03.23.
//

import SwiftUI

struct DirectionView: View {
    var direction: Direction
    
//    @Binding var timer: DirectionTimer
    
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
                if direction.hasTimer {
                    if done == false {
                        Button(action: {
                            //
                        }) {
                            Image(systemName: "timer")
                            Text("\(Int(direction.timerInMinutes)) min")
                        }
                        .foregroundColor(.white) // fontcolor
                        .buttonStyle(.borderedProminent)
                        .tint(.blue) // color background
                    }
                }
            }
            
        }
        .padding(.vertical)
    }
}

struct DirectionView_Previews: PreviewProvider {
    static var previews: some View {
        DirectionView(direction: Direction(step: 2, text: "2. Drink it all up for 2 minutes", hasTimer: true, timerInMinutes: 2))
    }
}