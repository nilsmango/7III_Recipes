//
//  IngredientsView.swift
//  MDRecipes
//
//  Created by Simon Lang on 30.03.23.
//

import SwiftUI

struct IngredientEditView: View {
    
    @Binding var ingredient: String
    
    @State private var selected = false
    
    var body: some View {
        HStack {
            
            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(selected ? .blue : .primary)
                .onTapGesture {
                    selected.toggle()
                }
            
            TextField("Amount Unit Ingredient", text: $ingredient)
        }
        
    }
    
}


struct IngredientEditView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientEditView(ingredient: .constant("10 kg carrots"))
    }
}
