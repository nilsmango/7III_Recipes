//
//  IngredientsEditView.swift
//  MDRecipes
//
//  Created by Simon Lang on 30.03.23.
//

import SwiftUI

struct IngredientsEditView: View {
    @Binding var ingredients: [String]
    
    @State private var newIngredient = ""
    
    @FocusState private var isFieldFocused: Bool
    
    @State private var selected = false
    
    var body: some View {
        
        ForEach(ingredients, id: \.self) { ingredient in
            IngredientEditView(ingredient: binding(ingredient: ingredient))
        }
        .onDelete { indices in
            ingredients.remove(atOffsets: indices)
        }
        .onMove { indices, newPlace in
            ingredients.move(fromOffsets: indices, toOffset: newPlace)
        }
        
            HStack {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(selected ? .blue : .primary)
                    .onTapGesture {
                        selected.toggle()
                    }
                TextField("10 kg carrots", text: $newIngredient)
                    .focused($isFieldFocused)
                    .onSubmit {
                        withAnimation {
                            ingredients.append(newIngredient)
                            newIngredient = ""
                            isFieldFocused = true
                        }
                    }
                if !newIngredient.isEmpty {
                    Button {
                            newIngredient = ""
                        
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .accessibilityLabel(Text("Delete"))
                            .foregroundColor(.secondary)

                    }
                }
                
        }
    }
    
    private func binding(ingredient: String) -> Binding<String> {
        guard let ingredientIndex = ingredients.firstIndex(where: { $0 == ingredient }) else {
            fatalError("Can't find the stupid ingredient in array")
        }
        return $ingredients[ingredientIndex]
    }
    
}



struct IngredientsEditView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            IngredientsEditView(ingredients: .constant(Recipe.sampleData[0].ingredients))
        }
        
    }
}
