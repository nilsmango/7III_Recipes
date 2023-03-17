//
//  ListItemView.swift
//  MDRecipes
//
//  Created by Simon Lang on 17.03.23.
//

import SwiftUI

struct ListItemView: View {
    var recipe: MarkdownFile
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(recipe.name)
                .accessibilityLabel("Recipe name")
            Text("Takes 5 minutes")
                .font(.caption)
        }
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemView(recipe: MarkdownFile.sampleData.first!)
    }
}
