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
    
    @Binding var direction: Direction
    var recipe: Recipe
    
    var timer: DirectionTimer
    
    // Directions Edit
    @State private var showDirectionsEdit = false
    @State private var directionsString = ""
    
    
    var body: some View {
        HStack {
            if direction.done {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
            VStack(alignment: .leading) {
                Text(direction.text)
//                                        .id(makeIndex(of: direction))
                    .strikethrough(direction.done ? true : false)
                    .onTapGesture {
                        
                        direction.done.toggle()
                        
                    }
                    .onLongPressGesture {
                        directionsString = recipe.directions.map({ $0.text }).joined(separator: "\n")
                        showDirectionsEdit = true
                    }

                if direction.done == false {
                    TimerButtonView(fileManager: fileManager, dirTimer: timer)
                    }
                }
        }
        .padding(.vertical)
        .onLongPressGesture {
            directionsString = recipe.directions.map({ $0.text }).joined(separator: "\n")
            showDirectionsEdit = true
        }
        
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

#Preview {
    DirectionTimerView(fileManager: RecipesManager(),direction: .constant(Direction(step: 2, text: "2. Drink it all up for 2 minutes", hasTimer: true, timerInMinutes: 2)), recipe: RecipesManager().recipes.first!, timer: DirectionTimer(targetDate: Date(timeIntervalSinceNow: 2344), timerInMinutes: 10, recipeTitle: "Misty Eye", stepString: "Let her rip for 10 minutes", step: 2, running: .running, id: UUID()))
}
