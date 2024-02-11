//
//  IngredientsEditView.swift
//  MDRecipes
//
//  Created by Simon Lang on 30.03.23.
//

import SwiftUI

struct IngredientsEditView: View {
    @Binding var ingredients: [Ingredient]
    
    @Binding var newIngredient: String
    
    @FocusState private var isFieldFocused: Bool
        
    var body: some View {
        
        ForEach(ingredients) { ingredient in
            IngredientEditView(ingredient: binding(for: ingredient))
        }
        .onDelete { indices in
            ingredients.remove(atOffsets: indices)
        }
        .onMove { indices, newPlace in
            ingredients.move(fromOffsets: indices, toOffset: newPlace)
        }
        
            HStack {
                Image(systemName: "circle")
                    .foregroundColor(.primary)
                TextField("10 kg carrots", text: $newIngredient)
                    .focused($isFieldFocused)
                    .onSubmit {
                        withAnimation {
                            submittingTextField()
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
    private func submittingTextField() {
        if newIngredient.trimmingCharacters(in: .whitespaces) != "" {
            ingredients.append(Ingredient(text: newIngredient.trimmingCharacters(in: .whitespaces)))
        }
        newIngredient = ""
        isFieldFocused = true
    }
    
    private func binding(for ingredient: Ingredient) -> Binding<Ingredient> {
        guard let ingredientIndex = ingredients.firstIndex(where: { $0.id == ingredient.id }) else {
            fatalError("Can't find the stupid ingredient in array")
        }
        return $ingredients[ingredientIndex]
    }
    
}



struct IngredientsEditView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            IngredientsEditView(ingredients: .constant(Recipe.sampleData[0].ingredients), newIngredient: .constant(""))
        }
        
    }
}
