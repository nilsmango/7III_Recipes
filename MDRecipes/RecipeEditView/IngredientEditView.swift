//
//  IngredientsView.swift
//  MDRecipes
//
//  Created by Simon Lang on 30.03.23.
//

import SwiftUI



struct IngredientEditView: View {

    @Binding var ingredient: Ingredient
    
    var body: some View {
        HStack {
            
            Image(systemName: ingredient.selected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(ingredient.selected ? .blue : .primary)
                .onTapGesture {
                    ingredient.selected.toggle()
                }
            
            TextField("Amount Unit Ingredient", text: $ingredient.text)
        }
        
    }
    
}


struct IngredientEditView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientEditView(ingredient: .constant(Ingredient(text: "10 kg carrots")))
    }
}
