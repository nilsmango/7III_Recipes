//
//  CategoriesView.swift
//  MDRecipes
//
//  Created by Simon Lang on 29.03.23.
//

import SwiftUI

struct CategoriesEditView: View {
    @Binding var categories: [String]
    
    @State private var newCategory = ""
    
    var fileManager: RecipesManager
    
    private var recipesCategories: [String] {
        fileManager.getAllCategories()
    }
    
    @State private var allCategories = [String]()
    
    @FocusState private var isFieldFocused: Bool
    
    var body: some View {
        Section {
            FlexibleView(
                data: allCategories,
                spacing: 5,
                alignment: .leading
            ) { category in
                Text(category)
                    .foregroundColor(categories.contains(category) ? .white : .gray)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .padding(8)
                    .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(categories.contains(category) ? .blue : .gray)
                                .opacity(categories.contains(category) ? 1 : 0.2)
                        
                    )
                    .onTapGesture {
                        withAnimation {
                            if categories.contains(category) {
                                categories.removeAll(where: { $0 == category })
                                allCategories = Array(Set(recipesCategories + categories)).sorted()
                            } else {
                                categories.append(category)
                                allCategories = Array(Set(recipesCategories + categories)).sorted()
                            }
                        }
                        
                        
                    }
                
            }
            }
        .onAppear {
            allCategories = Array(Set(recipesCategories + categories)).sorted()
        }
        Section {
            
            HStack {
                TextField("Add a new category ...", text: $newCategory)
                    .focused($isFieldFocused)
                    .onSubmit {
                        isFieldFocused = true
                        withAnimation {
                            categories.append(newCategory)
                            newCategory = ""
                            allCategories = Array(Set(recipesCategories + categories)).sorted()
                        }
                    }
                if !newCategory.isEmpty {
                    Button {
                        newCategory = ""
                        
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .accessibilityLabel(Text("Delete"))
                            .foregroundColor(.secondary)
                        
                    }
                }
            }
        }
    }
}

struct CategoriesEditView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            CategoriesEditView(categories: .constant(Recipe.sampleData[0].data.categories), fileManager: RecipesManager())
        }
        
    }
}
