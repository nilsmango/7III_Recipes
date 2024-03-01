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
                            .onChange(of: tagToAdd) { newValue in
                                var newTag = newValue
                                if !newTag.hasPrefix("#") {
                                    newTag = "#" + newTag
                                }
                                tagToAdd = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                            .foregroundStyle(addTag ? .primary : .secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(.buttonBG)
                            )
                            .frame(width: 170)
                            .padding(.bottom)
                        
                    }
                    
                    HStack {
                        Button(action: {
                            let tagForImport = addTag ? tagToAdd : ""
                            
                            showOverlay = false
                            
                            do {
                                let recipesImported = try recipesManager.importRecipes(url: fileURL, resetTimesCooked: resetTimesCooked, specialTag: tagForImport)
                                alertText = "\(recipesImported) recipes imported!"
                                alertPositive = true
                                showRecipesGotImported = true
                                
                            } catch {
                                alertText = "Error importing the recipes: \(error)"
                                alertPositive = false
                                showRecipesGotImported = true
                            }
                        }, label: {
                            Label("Import", systemImage: "checkmark")
                        })
                        .buttonStyle(.bordered)
                        
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
                .outsideTap {
                    showOverlay = false
                }
            }
            
            AlertOverlay(showAlert: $showRecipesGotImported, text: alertText, symbolPositive: alertPositive)
        }
    }
}

#Preview {
    ImportRecipesOverlay(recipesManager: RecipesManager(), showOverlay: .constant(true), fileURL: "")
}
