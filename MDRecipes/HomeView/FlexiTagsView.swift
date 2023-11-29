//
//  TagsView.swift
//  MDRecipes
//
//  Created by Simon Lang on 31.03.23.
//

import SwiftUI

struct FlexiTagsView: View {
    @ObservedObject var fileManager: RecipesManager
    
    var strings: [String]
    
    var body: some View {
        FlexibleView(
            data: strings,
            spacing: 5,
            alignment: .leading
        ) { string in
            NavigationLink(destination: TagsOrIngredientsListView(fileManager: fileManager, selectedString: string, allStrings: strings, isTags: true)) {

                Text(string)
                    .foregroundColor(.primary)
//                    .fontWeight(.bold)
//                    .fontDesign(.rounded)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("LightGray"))
                    )
            }
        }
    }
}

struct FlexiTagsView_Previews: PreviewProvider {
    static var previews: some View {
        FlexiTagsView(fileManager: RecipesManager(), strings: ["#SuckIt", "#motherFucker"])
    }
}
