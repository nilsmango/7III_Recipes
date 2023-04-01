//
//  HomeView.swift
//  MDRecipes
//
//  Created by Simon Lang on 20.03.23.
//

import SwiftUI

struct HomeView: View {    
    @ObservedObject var fileManager: MarkdownFileManager
    @ObservedObject var timerManager: TimerManager
    
    @State var searchText = ""
    
    
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            if searchText.isEmpty {
                ScrollView {
                    VStack {
                        LazyVGrid(columns: columns) {
                            NavigationLink(destination: RecipesListView(fileManager: fileManager, timerManager: timerManager, category: "")) {
                                FolderView(categoryFolder: "All", categoryNumber: String(fileManager.filterTheRecipes(string: "", ingredients: [], categories: [], tags: []).count))
                            }
                            
                            ForEach(fileManager.getAllCategories(), id: \.self) { category in
                                NavigationLink(destination: RecipesListView(fileManager: fileManager, timerManager: timerManager, category: category)) {
                                    FolderView(categoryFolder: category, categoryNumber: String(fileManager.filterTheRecipes(string: "", ingredients: [], categories: [category], tags: []).count))
                                        
                                }
                                
                                    
                            }
                            
                        }
                        
                        .padding()
                      
                    // TODO: make this great
                        
                        Text("Tags")
                        FlexiStringsView(strings: fileManager.getAllTags())
                        Text("Ingredients")
                        
                        
                        Text("Irgndwie Tags und ingredients here, wenn clickt dann zu einer speziellen liste mit ausgewählten tags oder eben ingredients, wo man einzelne tags oder ingredients dazuklicken kann wie TagsEditView - die neue liste hier unten hinzufügen bei else")
                        
                        Text("New Recipe Button auch irgendwo hier unten, als erstes!(?)")
                        Text("Alles wie in erinnerungen app")
                    }
                }
                
                .background(
                    .gray
                    .opacity(0.1)
                )
                .navigationTitle("Categories")
                
            } else {
                List {
  
                        ForEach(fileManager.getAllCategories(), id: \.self) { category in
                            if !fileManager.filterTheRecipes(string: searchText, ingredients: [], categories: [category], tags: []).isEmpty {
                                Section {
                                    ForEach(fileManager.filterTheRecipes(string: searchText, ingredients: [], categories: [category], tags: [])) { recipe in
                                        NavigationLink(destination: RecipeView(fileManager: fileManager, recipe: recipe, timerManager: timerManager)) {
                                            ListItemView(recipe: recipe)
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
            fileManager.recipes = Recipe.sampleData
            
        return HomeView(fileManager: fileManager, timerManager: TimerManager())
        }
    }

