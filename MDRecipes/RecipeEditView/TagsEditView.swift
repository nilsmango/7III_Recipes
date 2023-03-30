//
//  TagsView.swift
//  MDRecipes
//
//  Created by Simon Lang on 29.03.23.
//

import SwiftUI

struct TagsEditView: View {
    @Binding var tags: [String]
    
    var fileManager: MarkdownFileManager
    
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
    
    var body: some View {
        Section {
            FlexibleView(
                data: allTags,
                spacing: 5,
                alignment: .leading
            ) { tag in
                Text(tag)
                    .foregroundColor(tags.contains(tag) ? .white : .gray)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .padding(8)
                    .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(tags.contains(tag) ? .blue : .gray)
                                .opacity(tags.contains(tag) ? 1 : 0.2)
                        
                    )
                    .onTapGesture {
                        withAnimation {
                            if tags.contains(tag) {
                                tags.removeAll(where: { $0 == tag })
                                allTags = Array(Set(recipesTags + tags)).sorted()
                            } else {
                                tags.append(tag)
                                allTags = Array(Set(recipesTags + tags)).sorted()
                            }
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
                                allTags = Array(Set(recipesTags + tags)).sorted()
                            }
                            
                        
                    }
            .disableAutocorrection(true)
            .autocapitalization(.none)
                .onChange(of: newTag) { newValue in
                    if canMakeTag(from: newTag) {
                        withAnimation {
                            tags.append(makeWordTag(newTag))
                            newTag = ""
                            allTags = Array(Set(recipesTags + tags)).sorted()
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
            TagsEditView(tags: .constant(Recipe.sampleData[0].data.tags), fileManager: MarkdownFileManager())
        }
        
    }
}