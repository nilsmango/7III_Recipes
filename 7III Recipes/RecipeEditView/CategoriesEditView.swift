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
        fileManager.categories
    }
    
    @State private var allCategories = [String]()
    
    @FocusState private var isFieldFocused: Bool
    
    private func removeNoCategoryIfItsSelected() {
        if categories.contains(Constants.noCategoryFolder) {
            categories.removeAll(where: { $0 == Constants.noCategoryFolder})
        }
    }
    
    var body: some View {
        Section {
            FlexibleView(
                data: allCategories,
                spacing: 5,
                alignment: .leading
            ) { category in
                SelectionButtonLabel(string: category, chosenStrings: $categories, allStrings: categories)
                    .onTapGesture {
                            if categories.contains(category) {
                                categories.removeAll(where: { $0 == category })
                                allCategories = Array(Set(recipesCategories + categories)).sorted()
                                if categories.isEmpty {
                                    categories.append(Constants.noCategoryFolder)
                                }
                            } else {
                                categories.append(category)
                                if categories.contains(Constants.noCategoryFolder) {
                                    categories.removeAll(where: { $0 == Constants.noCategoryFolder})
                                }
                                allCategories = Array(Set(recipesCategories + categories)).sorted()
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
                    .autocapitalization(.words)
                    .focused($isFieldFocused)
                    .onSubmit {
                        isFieldFocused = true
                        withAnimation {
                            categories.append(newCategory.capitalized)
                            if categories.contains(Constants.noCategoryFolder) {
                                categories.removeAll(where: { $0 == Constants.noCategoryFolder})
                            }
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
