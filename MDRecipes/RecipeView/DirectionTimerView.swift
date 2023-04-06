//
//  DirectionTimerView.swift
//  MDRecipes
//
//  Created by Simon Lang on 01.04.23.
//

import SwiftUI

import SwiftUI

struct DirectionTimerView: View {
    @ObservedObject var fileManager: RecipesManager
//    @ObservedObject var timerManager: TimerManager
    
    var direction: Direction
    var recipe: Recipe
    
    @Binding var timer: DirectionTimer
    
    
    
    // Step done indicator.
    @State private var done = false
    
    // Directions Edit
    @State private var showDirectionsEdit = false
    @State private var directionsString = ""
    
    
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
                    .onLongPressGesture {
                        directionsString = recipe.directions.map({ $0.text }).joined(separator: "\n")
                        showDirectionsEdit = true
                    }

                if done == false && timer.timerInMinutes > 0.9 {
                        Button(action: {
                            
                                timer.running.toggle()
                            
                            
                        }) {
                            Image(systemName: "timer")
                            if timer.running {
                                Text(timer.targetDate, style: .timer)
                                    .monospacedDigit()
                            } else {
                                Text("\(Int(timer.timerInMinutes)) min")
                            }
                        }
                        .foregroundColor(.white)
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    }
                }
        }
        .padding(.vertical)
        
        .sheet(isPresented: $showDirectionsEdit) {
            NavigationView {
                DirectionsEditTextView(directionsData: $directionsString)
                    .navigationTitle("Edit Directions")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showDirectionsEdit = false
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Update") {
                                showDirectionsEdit = false
                                
                                // update the directions of this recipe
                                fileManager.updatingDirectionsOfRecipe(directionsString: directionsString, of: recipe)
                                
                                
                            }
                        }
                    }
            }
        }
    }
}

struct DirectionTimerView_Previews: PreviewProvider {
    static var previews: some View {
        DirectionTimerView(fileManager: RecipesManager() ,direction: Direction(step: 2, text: "2. Drink it all up for 2 minutes", hasTimer: true, timerInMinutes: 2), recipe: RecipesManager().recipes.first!, timer: .constant(DirectionTimer(targetDate: Date(timeIntervalSinceNow: 2344), timerInMinutes: 10, recipeTitle: "Misty Eye", step: 2, running: true, id: UUID())))
    }
}

