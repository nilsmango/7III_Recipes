//
//  TagsOrIngredientsListView.swift
//  7III Recipes
//
//  Created by Simon Lang on 28.11.23.
//

import SwiftUI

struct TagsOrIngredientsListView: View {
    @ObservedObject var recipesManager: RecipesManager
    
    @State private var editMode: EditMode = .inactive
    
    var allStrings: [String]
    
    var isTags: Bool
    
    @State private var showDoneAlert = false
    @State private var doneAlertText = ""
    
    var body: some View {
        // add a row of FlexibleView items that are buttons that will get added to the tags
        VStack {
            
            FlexibleView(
                data: allStrings,
                spacing: 5,
                alignment: .leading
            ) { string in
                
                SelectionButtonLabel(string: string, chosenStrings: $recipesManager.chosenTags, allStrings: allStrings)
                    .onTapGesture {
                        if recipesManager.chosenTags.contains(string) {
                            recipesManager.chosenTags.removeAll(where: { $0 == string})
                        } else {
                            recipesManager.chosenTags.append(string)
                        }
                    }
                    .contextMenu {
                        TagsContextMenu(recipesManager: recipesManager, tag: string)
                    }
            }
            .padding()
            
            List {
                ForEach(recipesManager.categories, id: \.self) { category in
                    if !recipesManager.filterTheRecipes(string: "", ingredients: isTags ? [] : recipesManager.chosenTags, categories: [category], tags: isTags ? recipesManager.chosenTags : []).isEmpty {
                        Section {
                            ForEach(recipesManager.filterTheRecipes(string: "", ingredients: isTags ? [] : recipesManager.chosenTags, categories: [category], tags: isTags ? recipesManager.chosenTags : [])) { recipe in
                                NavigationLink(value: recipe) {
                                    ListItemView(recipe: recipe)
                                }
                            }
                            .onDelete { indexSet in
                                recipesManager.delete(at: indexSet, filteringCategory: category, filteringTags: true)
                            }
                        } header: {
                            Text(category)
                                .font(.title3)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                        }
                        .listStyle(.insetGrouped)
                    }
                }
            }
        }
        .background(
            .gray
                .opacity(0.1)
        )
        .navigationTitle(Text(recipesManager.chosenTags.count < 2 ? recipesManager.chosenTags.first ?? "Filter by Tags" : recipesManager.chosenTags.first! + " +"))
        
    }
}

#Preview {
    TagsOrIngredientsListView(recipesManager: RecipesManager(), allStrings: ["#Bitch", "#Watermelon", "#SomeOtherTag", "#Funny", "#Crazy"], isTags: true)
}
