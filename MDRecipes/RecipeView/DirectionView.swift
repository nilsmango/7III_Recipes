//
//  DirectionView.swift
//  MDRecipes
//
//  Created by Simon Lang on 27.03.23.
//

import SwiftUI

struct DirectionView: View {
    @ObservedObject var fileManager: RecipesManager
    
    var direction: Direction
    var recipe: Recipe
    
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

struct DirectionView_Previews: PreviewProvider {
    static var previews: some View {
        DirectionView(fileManager: RecipesManager(), direction: Direction(step: 2, text: "2. Drink it all up for 2 minutes", hasTimer: false, timerInMinutes: 2), recipe: RecipesManager().recipes.first!)
    }
}
