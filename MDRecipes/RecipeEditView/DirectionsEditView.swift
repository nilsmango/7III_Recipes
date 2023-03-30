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
    
    var body: some View {
        ForEach(directions) { direction in
            Text(direction.text)
        }
        HStack{
            TextEditor(text: $newDirection)
            Button {
                let count = directions.count
                if newDirection.range(of: #"^\d+\."#, options: .regularExpression) != nil {
                    newDirection = String(newDirection.dropFirst(3))
                }
                directions.append(Parser.createDirection(from: newDirection, directionsCount: directions.count))
                newDirection = ""
            } label: {
                Image(systemName: "plus.circle")
                    .accessibilityLabel(Text("Add Step"))
                
            }
            .disabled(newDirection.isEmpty)
            .buttonStyle(.bordered)
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
