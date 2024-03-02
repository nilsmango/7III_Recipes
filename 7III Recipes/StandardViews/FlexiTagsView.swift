//
//  TagsView.swift
//  MDRecipes
//
//  Created by Simon Lang on 31.03.23.
//

import SwiftUI

struct FlexiTagsView: View {
    @ObservedObject var recipesManager: RecipesManager
    
    var tags: [String]
    
    var body: some View {
        FlexibleView(
            data: tags,
            spacing: 5,
            alignment: .leading
        ) { tag in
            Button(action: {
                recipesManager.path.append(TagSelection(tag: tag))
                recipesManager.chosenTags = [tag]
            }, label: {
                Text(tag)
                    .foregroundColor(.primary)
//                    .fontWeight(.bold)
//                    .fontDesign(.rounded)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("CustomLightGray"))
                    )
            })
            .contextMenu {
                TagsContextMenu(recipesManager: recipesManager, tag: tag)
            }
        }
        .navigationDestination(for: TagSelection.self) { tagSelection in
            TagsOrIngredientsListView(recipesManager: recipesManager, allStrings: tags, isTags: true)
        }
    }
}

#Preview {
    FlexiTagsView(recipesManager: RecipesManager(), tags: ["#SuckIt", "#motherFucker"])
    }
