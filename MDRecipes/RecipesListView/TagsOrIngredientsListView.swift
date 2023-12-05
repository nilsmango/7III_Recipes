//
//  TagsOrIngredientsListView.swift
//  7III Recipes
//
//  Created by Simon Lang on 28.11.23.
//

import SwiftUI

struct TagsOrIngredientsListView: View {
    @ObservedObject var fileManager: RecipesManager
    
    var selectedString: String
    
    @State var chosenStrings = [String]()
    
    var allStrings: [String]
    
    var isTags: Bool
    
    var body: some View {
        // add a row of FlexibleView items that are buttons that will get added to the tags
        VStack {
            
        
        FlexibleView(
            data: allStrings,
            spacing: 5,
            alignment: .leading
        ) { string in

            SelectionButtonLabel(string: string, chosenStrings: $chosenStrings, allStrings: allStrings)
                .onTapGesture {
                        if chosenStrings.contains(string) {
                            chosenStrings.removeAll(where: { $0 == string})
                        } else {
                            chosenStrings.append(string)
                        }
                }
        }
        .padding()
            .onAppear {
                    chosenStrings.append(selectedString)
            }
        List {
            ForEach(fileManager.filterTheRecipes(string: "", ingredients: isTags ? [] : chosenStrings, categories: [], tags: isTags ? chosenStrings : [])) { recipe in
                NavigationLink(destination: RecipeView(fileManager: fileManager,recipe: recipe, categoryFolder: "", recipeMovedAlert: .constant(RecipeMovedAlert(showAlert: false, recipeName: "", movedToCategory: "")))) {
                    ListItemView(recipe: recipe)
                }
                .listStyle(.insetGrouped)
                
            }
        }
        }
        .background(
            .gray
                .opacity(0.1)
        )
        .navigationTitle(Text(chosenStrings.count < 2 ? chosenStrings.first ?? "Filter by Tags" : chosenStrings.first! + " +"))
    }
}

#Preview {
    TagsOrIngredientsListView(fileManager: RecipesManager(), selectedString: "#Bitch", allStrings: ["#Bitch", "#Watermelon", "#SomeOtherTag", "#Funny", "#Crazy"], isTags: true)
}
