//
//  TagsView.swift
//  MDRecipes
//
//  Created by Simon Lang on 29.03.23.
//

import SwiftUI

struct TagsEditView: View {
    @Binding var tags: [String]
    
    var fileManager: RecipesManager
    
    private var recipesTags: [String] {
        fileManager.getAllTags()
    }
    
    @State private var allTags = [String]()
    
    @State private var newTag = ""
    
    @FocusState private var isFieldFocused: Bool
    
    private func makeWordTag(_ word: String) -> String {
        let cleanWord = word.trimmingCharacters(in: .whitespaces)
        if cleanWord.hasPrefix("#") {
            return cleanWord
        } else {
            return "#" + cleanWord
        }
    }
    
    private func canMakeTag(from word: String) -> Bool {
        if word.hasSuffix(" ") || word.hasSuffix("\n") {
            return true
        } else {
            return false
        }
    }
    
    private func updateAllTags() {
        allTags = Array(Set(recipesTags + tags)).sorted()
    }
    
    var body: some View {
        Section {
            FlexibleView(
                data: allTags,
                spacing: 5,
                alignment: .leading
            ) { tag in
                SelectionButtonLabel(string: tag, chosenStrings: $tags, allStrings: recipesTags)
                    .onTapGesture {
                            if tags.contains(tag) {
                                tags.removeAll(where: { $0 == tag })
                                updateAllTags()
                            } else {
                                    tags.append(tag)
                                    updateAllTags()
                            }
                    }
            }
        }
        .onAppear {
            allTags = Array(Set(recipesTags + tags)).sorted()
        }
        Section {
            HStack {
                TextField("Add a new tag ...", text: $newTag)
                    .focused($isFieldFocused)
                    .onSubmit {
                        isFieldFocused = true
                        withAnimation {
                            tags.append(makeWordTag(newTag))
                            newTag = ""
                            updateAllTags()
                        }
                    }
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .onChange(of: newTag) { newValue in
                        if canMakeTag(from: newTag) {
                            withAnimation {
                                tags.append(makeWordTag(newTag))
                                newTag = ""
                                updateAllTags()
                            }
                            
                        }
                    }
                
                if !newTag.isEmpty {
                    Button {
                        newTag = ""
                        
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

struct TagsEditView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            TagsEditView(tags: .constant(Recipe.sampleData[0].data.tags), fileManager: RecipesManager())
        }
        
    }
}
