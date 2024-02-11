//
//  DirectionsEditView.swift
//  MDRecipes
//
//  Created by Simon Lang on 29.03.23.
//

import SwiftUI

struct DirectionsEditView: View {
    @Binding var directions: [Direction]
    
    @State private var newDirection = ""
    
    @FocusState private var isFieldFocused: Bool
    
    // Directions Edit
    @State private var showDirectionsEdit = false
    @State private var directionsString = ""
    
    var body: some View {
        ForEach(directions) { direction in
            
                
                Text(direction.text)

            
            .padding(.vertical)
        }
        .onTapGesture {
            directionsString = directions.map( { $0.text }).joined(separator: "\n")
            
            showDirectionsEdit = true
        }
        
        HStack{
            ZStack(alignment: .leading) {
                TextEditor(text: $newDirection)
                    .focused($isFieldFocused)
                   
                // this text is to disable the scrolling
                Text(newDirection)
                    .padding(.all, 9)
                    .opacity(0)
            }
            .padding(.top)
            Button {
                if newDirection.range(of: #"^\d+\."#, options: .regularExpression) != nil {
                    newDirection = String(newDirection.dropFirst(3))
                }
                directions.append(Parser.createDirection(from: newDirection, directionsCount: directions.count))
                newDirection = ""
                isFieldFocused = true
                
            } label: {
                Image(systemName: "plus.circle")
                    .accessibilityLabel(Text("Add Step"))
                
            }
            .disabled(newDirection.isEmpty)
            .buttonStyle(.bordered)
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
                                
                                // update the directions of this recipe.data
                                // TODO: try it with reparsing or edit this one? we need to find the the recipe we are in if it's not a new one and then line for line bind old ID's to new directions
                                let newDirections = Parser.makingDirectionsFromString(directionsString: directionsString)
                                
                                directions = newDirections
//                                directions = Parser.makeNewDirectionsWithOldID(newDirections: newDirections, oldDirections: directions)
                                
                            }
                        }
                    }
            }
        }
    }
    
    
    
}

struct DirectionsEditView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            DirectionsEditView(directions: .constant(Recipe.sampleData[0].directions))
        }
        
    }
}
