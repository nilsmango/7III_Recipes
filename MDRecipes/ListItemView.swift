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
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(recipe.name)
                .accessibilityLabel("Recipe name")
            Text("Takes \(String(fileManager.extractTotalTime(from: recipe.content))) minutes")
                .font(.caption)
        }
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemView(fileManager: MarkdownFileManager(), recipe: MarkdownFile.sampleData.first!)
    }
}
