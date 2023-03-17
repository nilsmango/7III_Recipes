//
//  RecipeView.swift
//  MDRecipes
//
//  Created by Simon Lang on 17.03.23.
//

import SwiftUI

struct RecipeView: View {
    var recipe: MarkdownFile
    
    var body: some View {
        Text(recipe.content)
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView(recipe: MarkdownFile.sampleData.first!)
    }
}
