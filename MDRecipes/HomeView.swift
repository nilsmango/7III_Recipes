//
//  HomeView.swift
//  MDRecipes
//
//  Created by Simon Lang on 20.03.23.
//

import SwiftUI

struct HomeView: View {    
    @ObservedObject var fileManager: MarkdownFileManager
    
    @State private var searchText = ""
    
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            if searchText.isEmpty {
                ScrollView {
                    VStack {
                        
                        LazyVGrid(columns: columns) {
                            NavigationLink(destination: RecipesListView(fileManager: fileManager, category: "")) {
                                FolderView(categoryFolder: "All", categoryNumber: String(fileManager.filterTheRecipes(string: "", ingredients: [], categories: [], tags: []).count))
                            }
                                
                            ForEach(fileManager.getAllCategories(), id: \.self) { category in
                                NavigationLink(destination: RecipesListView(fileManager: fileManager, category: category)) {
                                    FolderView(categoryFolder: category, categoryNumber: String(fileManager.filterTheRecipes(string: "", ingredients: [], categories: [category], tags: []).count))
                                        
                                }
                                
                                    
                            }
                            
                        }
                        
                        .padding()
                      
                    // TODO: make this great
                        
                        Text("Irgndwie Tags und ingredients here, wenn clickt dann zu einer liste mit ausgewählten tags etc.")
                        Text("New Recipe Button auch irgendwo hier unten, als erstes!(?)")
                    }
                }
                
                .background(
                    .gray
                    .opacity(0.1)
                )
                .navigationTitle("Categories")
                
            } else {
                List {
  
                    
                    // TODO: make that list into sections of the categories!
                    
                        ForEach(fileManager.getAllCategories(), id: \.self) { category in
                            if !fileManager.filterTheRecipes(string: searchText, ingredients: [], categories: [category], tags: []).isEmpty {
                                Section {
                                    ForEach(fileManager.filterTheRecipes(string: searchText, ingredients: [], categories: [category], tags: [])) { recipe in
                                        NavigationLink(destination: RecipeView(recipe: recipe)) {
                                            ListItemView(fileManager: fileManager, recipe: recipe)
                                        }
                                        
                                    }
                                
                                } header: {
                                    Text(category)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .fontDesign(.rounded)
                                }
                            }
                            
                        
                    }
                    
                }
                .listStyle(.inset)
            }
            
                
            
            
            
            
                
        }
        .scrollContentBackground(.hidden)
        .searchable(text: $searchText)
        .background(ignoresSafeAreaEdges: .all)
        
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
            let fileManager = MarkdownFileManager()
            fileManager.markdownFiles = MarkdownFile.sampleData
            
            return HomeView(fileManager: fileManager)
        }
    }

