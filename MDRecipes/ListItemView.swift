//
//  ListItemView.swift
//  MDRecipes
//
//  Created by Simon Lang on 17.03.23.
//

import SwiftUI

struct ListItemView: View {
    @ObservedObject var fileManager: MarkdownFileManager
    var recipe: MarkdownFile
    var rating: String { fileManager.extractRating(from: recipe.content) }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(recipe.name)
                .accessibilityLabel("Recipe name")
            HStack {
                Image(systemName: "clock")
                Text("\(String(fileManager.extractTotalTime(from: recipe.content))) min")
                if rating != "-" {
                    Image(systemName: "star")
                    Text(rating)
                }
                
                
                    
            }
            .font(.caption)
            
        }
        
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemView(fileManager: MarkdownFileManager(), recipe: MarkdownFile.sampleData.first!)
    }
}
