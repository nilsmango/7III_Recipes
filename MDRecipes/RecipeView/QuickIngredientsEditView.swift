//
//  QuickIngredientsEditView.swift
//  MDRecipes
//
//  Created by Simon Lang on 06.04.23.
//

import SwiftUI

struct QuickIngredientsEditView: View {
    @Binding var ingredients: [Ingredient]
    
    var servings: Int
    
    var body: some View {
        List {
            Section {
                Text("Servings: \(servings)")
            }
            Section("Ingredients") {
                IngredientsEditView(ingredients: $ingredients)
            }
            
        }
    }
}

struct QuickIngredientsEditView_Previews: PreviewProvider {
    static var previews: some View {
        QuickIngredientsEditView(ingredients: .constant(Recipe.sampleData[0].ingredients), servings: 4)
    }
}
