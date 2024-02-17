//
//  TagsView.swift
//  MDRecipes
//
//  Created by Simon Lang on 31.03.23.
//

import SwiftUI

struct FlexiTagsView: View {
    @ObservedObject var recipesManager: RecipesManager
    
    var strings: [String]
    
    var body: some View {
        FlexibleView(
            data: strings,
            spacing: 5,
            alignment: .leading
        ) { string in
            Button(action: {
                recipesManager.path.append(TagSelection(tag: string))
                recipesManager.chosenTags.append(string)
            }, label: {
                Text(string)
                    .foregroundColor(.primary)
//                    .fontWeight(.bold)
//                    .fontDesign(.rounded)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("CustomLightGray"))
                    )
            })
        }
        .navigationDestination(for: TagSelection.self) { tagSelection in
            TagsOrIngredientsListView(recipesManager: recipesManager, allStrings: strings, isTags: true)
        }
    }
}

struct FlexiTagsView_Previews: PreviewProvider {
    static var previews: some View {
        FlexiTagsView(recipesManager: RecipesManager(), strings: ["#SuckIt", "#motherFucker"])
    }
}
