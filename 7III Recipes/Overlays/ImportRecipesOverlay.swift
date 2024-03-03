//
//  ImportZipOverlay.swift
//  7III Recipes
//
//  Created by Simon Lang on 28.02.2024.
//

import SwiftUI

struct ImportRecipesOverlay: View {
    @ObservedObject var recipesManager: RecipesManager
    
    @Binding var showOverlay: Bool
    
    var fileURL: String
    
    @State private var addTag = false
    @State private var tagToAdd = ""
    @State private var resetTimesCooked = false
    @State private var deleteFolder = false
    
    @State private var showRecipesGotImported = false
    @State private var alertText = ""
    @State private var alertPositive = true
    
    var body: some View {
        ZStack {
            if showOverlay {
                VStack {
                    Text("Import Recipes")
                        .font(.headline)
                        .padding()
                    
                    VStack(spacing: 12) {
                        
                        HStack {
                            Image(systemName: resetTimesCooked ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(resetTimesCooked ? .blue : .primary)
                            
                            Text("Reset times cooked counters")
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            resetTimesCooked.toggle()
                        }
                        
                        HStack {
                            Image(systemName: deleteFolder ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(deleteFolder ? .blue : .primary)
                            
                            Text("Delete folder during import")
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            deleteFolder.toggle()
                        }
                        
                        HStack {
                            Image(systemName: addTag ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(addTag ? .blue : .primary)
                            
                            Text("Add a tag to every recipe")
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            addTag.toggle()
                        }
                        TextField("#yourTag", text: $tagToAdd)
                            .tagTextField(text: $tagToAdd, active: addTag)
                        
                    }
                    
                    HStack {
                        Button(action: {
                            let tagForImport = addTag ? tagToAdd : ""
                            showOverlay = false
                            
                            do {
                                let recipesImported = try recipesManager.importRecipes(url: fileURL, resetTimesCooked: resetTimesCooked, specialTag: tagForImport, deleteFolder: deleteFolder)
                                alertText = "\(recipesImported) recipes imported!"
                                alertPositive = true
                                showRecipesGotImported = true
                                
                                // reset values
                                tagToAdd = ""
                                addTag = false
                                deleteFolder = false
                                resetTimesCooked = false
                                
                            } catch {
                                alertText = "Error importing the recipes.\n\nIf you tried to import files, use the \"Import File(s)\" option in the menu located at the top right-hand corner instead."
                                alertPositive = false
                                showRecipesGotImported = true
                                
                                // reset values
                                tagToAdd = ""
                                addTag = false
                                deleteFolder = false
                                resetTimesCooked = false
                            }
                        }, label: {
                            Label("Import", systemImage: "checkmark")
                        })
                        .buttonStyle(.bordered)
                        .disabled(addTag && ( tagToAdd == "" || tagToAdd == "#" ))
                        
                        Button(role: .destructive, action: {
                            showOverlay = false
                        }, label: {
                            Label("Cancel", systemImage: "xmark")
                        })
                        .buttonStyle(.bordered)
                    }
                    .padding(.bottom)
                }
                .overlayVStack()
            }
            
            AlertOverlay(showAlert: $showRecipesGotImported, text: alertText, symbolPositive: alertPositive)
            
        }
    }
}

#Preview {
    ImportRecipesOverlay(recipesManager: RecipesManager(), showOverlay: .constant(true), fileURL: "")
}
