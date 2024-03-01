//
//  HomeRecipesFolderView.swift
//  7III Recipes
//
//  Created by Simon Lang on 01.03.2024.
//

import SwiftUI

struct HomeRecipesFolderView: View {
    @ObservedObject var recipesManager: RecipesManager
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @Binding var editViewPresented: Bool
    @Binding var importViewPresented: Bool
    
    @State private var showNewRecipeButtons = false
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .leading) {
                let allRecipes = recipesManager.filterTheRecipes(string: "", ingredients: [], categories: [], tags: []).count
                
                if allRecipes > 0 {
                    Text("7III Recipes")
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .padding([.horizontal, .top])
                    LazyVGrid(columns: columns) {
                        Button {
                            recipesManager.path.append("")
                            // updating our navigation tools
                            recipesManager.currentCategory = "All"
                            recipesManager.chosenTags = []
                        } label: {
                            FolderView(categoryFolder: "All", categoryNumber: String(allRecipes))
                        }
                        
                        ForEach(recipesManager.categories, id: \.self) { category in
                            Button {
                                recipesManager.path.append(category)
                                // updating our navigation tools
                                recipesManager.currentCategory = category
                                recipesManager.chosenTags = []
                            } label: {
                                FolderView(categoryFolder: category, categoryNumber: String(recipesManager.filterTheRecipes(string: "", ingredients: [], categories: [category], tags: []).count))
                            }
                        }
                        
                        if allRecipes > 1 {
                            Button {
                                recipesManager.path.append(recipesManager.randomRecipe()!)
                                // updating our navigation tools
                                recipesManager.currentCategory = "All"
                                recipesManager.chosenTags = []
                            } label: {
                                RandomRecipeView()
                            }
                        }
                    }
                    .padding([.horizontal])
                    
                    let allTags = recipesManager.tags
                    if allTags.count > 0 {
                        Text("Tags")
                            .font(.title3)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .padding([.horizontal, .top])
                        
                        FlexiTagsView(recipesManager: recipesManager, strings: allTags)
                            .padding(.horizontal)
                    }
                    
                }
                HStack {
                    Spacer()
                    
                    if showNewRecipeButtons {
                        Button(action: {
                            editViewPresented = true
                            showNewRecipeButtons = false
                        }) {
                            Label("Write New", systemImage: "square.and.pencil")
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor(Color("FolderBG"))
                                )
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            importViewPresented = true
                            showNewRecipeButtons = false
                        }) {
                            Label("From Text", systemImage: "text.viewfinder")
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor(Color("FolderBG"))
                                )
                        }
                    } else {
                        Button(action: {
                            showNewRecipeButtons = true
                        }) {
                            Label("Add new Recipe", systemImage: "plus.circle.fill")
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor(Color("FolderBG"))
                                )
                        }
                        
                    }
                    
                    Spacer()
                }
                .padding()
                
            }
        }
    }
}

#Preview {
    HomeRecipesFolderView(recipesManager: RecipesManager(), editViewPresented: .constant(false), importViewPresented: .constant(false))
}
