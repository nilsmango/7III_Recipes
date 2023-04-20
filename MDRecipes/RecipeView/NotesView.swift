//
//  NotesView.swift
//  MDRecipes
//
//  Created by Simon Lang on 16.04.23.
//

import SwiftUI

struct NotesView: View {
    var recipe: Recipe
    
    @ObservedObject var fileManager: RecipesManager
    
    @State private var editing = false
    
    @State private var newNote = ""
    
    @FocusState private var isFieldFocused: Bool
    
    var body: some View {
        
        if editing == false {
            ZStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Button {
                        newNote = recipe.notes
                        editing = true
                        isFieldFocused = true
                        
                    } label: {
                        Label(recipe.notes == "" ? "Add Notes" : "Edit Notes", systemImage: "square.and.pencil")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.bordered)
                }
                Text(recipe.notes)
            }
            
            
        } else {
            VStack {
                ZStack {
                    TextEditor(text: $newNote)
                        .focused($isFieldFocused)
                    Text(newNote)
                        .opacity(0)
                }
                .padding(.bottom, 8)
                HStack {
                    Button {
                        editing = false
                    } label: {
                        Label("Cancel", systemImage: "xmark.circle")
                    }
                    .buttonStyle(.bordered)
                    Button {
                        editing = false
                        fileManager.updateNoteSection(of: recipe, to: newNote)
                        
                    } label: {
                        Label("Save", systemImage: "checkmark.circle")
                    }
                    .buttonStyle(.bordered)
                }
              
            }
            
        }
        
    }
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            NotesView(recipe: Recipe.sampleData[0], fileManager: RecipesManager())
        }
        
    }
}
