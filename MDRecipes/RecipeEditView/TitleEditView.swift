//
//  TitleEditView.swift
//  MDRecipes
//
//  Created by Simon Lang on 02.04.23.
//

import SwiftUI

struct TitleEditView: View {
    @Binding var title: String
    
    @State private var badTitle = false
    
    // all titles of all the recipes
    var titles: [String]
    
    // sanitized version of all titles
    private var saneTitles: [String] {
        titles.map({ Parser.sanitizeFileName($0) })
    }
    
    /// checking if title and also sanitized title is not in all titles and if title is not the oldTitle if we are editing the recipe
    private var invalidTitle: Bool {
        ( titles.contains(title) || saneTitles.contains(Parser.sanitizeFileName(title)) ) && title != oldTitle
    }
    
    let comingFromImportView: Bool
    
    @FocusState private var titleIsFocused: Bool
    
    @State var oldTitle = "Some title you would never think of"
    
    /// creating a unique title
    private func createUniqueTitle() {
        
        if invalidTitle  {
            
            for versionNumber in (2...200) {
                // if last character is a number then increase that number
                if let lastNumber = Int(String(title.last ?? "r")) {
                    let incrementedLastDigit = lastNumber + 1
                    let newTitle = String(title.dropLast()) + String(incrementedLastDigit)
                    title = newTitle
                    
                } else {
                    // adding a funny version number to the title if there is no number in the last character
                    title = title + " No. \(versionNumber)"
                }
                // check if new title is unique, else try again.
                if !invalidTitle {
                    return
                }
            }
        }
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Title:")
                TextField("Carrot Cake", text: $title)
                    .focused($titleIsFocused)
                
                    .onChange(of: title) { newValue in
                        if invalidTitle {
                            badTitle = true
                        } else {
                            badTitle = false
                        }
                    }
                    .onChange(of: titleIsFocused) { newValue in
                        createUniqueTitle()
                    }
                    .onSubmit {
                        createUniqueTitle()
                    }
                
                    .onAppear {
                        if comingFromImportView {
                            createUniqueTitle()
                        } else {
                            if title != "" {
                                oldTitle = title
                            }
                        }
                    }
            }
            if badTitle {
                Text("Title already taken, choose another one or we will change it for you.")
                    .font(.caption)
            }
            
        }
    }
}

struct TitleEditView_Previews: PreviewProvider {
    static var previews: some View {
        TitleEditView(title: .constant("Testing"), titles: ["Testing", "Other Title"], comingFromImportView: false)
    }
}
