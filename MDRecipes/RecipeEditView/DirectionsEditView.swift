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
            ZStack(alignment: .leading) {
                TextEditor(text: binding(direction: direction).text)
                // this text is to disable the scrolling of the textEditor
                Text(direction.text)
                    .padding(.all, 8)
                    .opacity(0)
            }
            .padding(.top)
        }
        HStack{
            ZStack(alignment: .leading) {
                TextEditor(text: $newDirection)
                // this text is to disable the scrolling
                Text(newDirection)
                    .padding(.all, 8)
                    .opacity(0)
            }
            .padding(.top)
            Button {
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
    
    private func binding(direction: Direction) -> Binding<Direction> {
        guard let ingredientIndex = directions.firstIndex(where: { $0.id == direction.id }) else {
            fatalError("Can't find the stupid ingredient in array")
        }
        return $directions[ingredientIndex]
    }
    
}

struct DirectionsEditView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            DirectionsEditView(directions: .constant(Recipe.sampleData[0].directions))
        }
        
    }
}
