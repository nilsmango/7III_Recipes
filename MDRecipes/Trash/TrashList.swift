//
//  TrashList.swift
//  MDRecipes
//
//  Created by Simon Lang on 02.04.23.
//

import SwiftUI

struct TrashList: View {
    @ObservedObject var fileManager: RecipesManager
    
    let calendar = Calendar.current
    
    var body: some View {
        List {
            ForEach(fileManager.trash) { recipe in
                VStack(alignment: .leading) {
                    Text(recipe.title)
                        .font(.title)
                    Text("Will get deleted in: \(Parser.daysUntilDeletion(recipe.updated)) days")
                    
                    Button {
                        fileManager.restoreRecipe(recipe: recipe)
                    } label: {
                        Text("Restore Recipe")
                    }
                    .buttonStyle(.borderedProminent)

                }
                
            }
        }
    }
}

struct TrashList_Previews: PreviewProvider {
    static var previews: some View {
        TrashList(fileManager: RecipesManager())
    }
}
