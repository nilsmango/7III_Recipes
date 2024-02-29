//
//  ExportRecipesOverlay.swift
//  7III Recipes
//
//  Created by Simon Lang on 29.02.2024.
//

import SwiftUI

struct ExportRecipesOverlay: View {
    @ObservedObject var recipesManager: RecipesManager

    @Binding var showExportOverlay: Bool
    var recipes: [Recipe]
    
    @State private var addTag = false
    @State private var tagToAdd = ""
    @State private var resetTimesCooked = false
    @State private var includeImages = false
    
    @State private var showStatusOverlay = false
    @State private var showShareLink = false
    var body: some View {
        if showStatusOverlay {
            
            ExportLinkOverlay(showShareLink: showShareLink, item: recipesManager.recipesDirectory.appendingPathComponent(Constants.exportFolder)) {
                // Close overlays, delete folder
                showExportOverlay = false
                showStatusOverlay = false
                recipesManager.removeExportFolder()
            }
            
        } else {
            VStack {
                Text("Export Recipes")
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
                        Image(systemName: includeImages ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(includeImages ? .blue : .primary)
                        
                        Text("Include images in export")
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        includeImages.toggle()
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
                        let tagForExport = addTag ? tagToAdd : ""
                        
                        showStatusOverlay = true
                        
                        recipesManager.exportRecipes(recipes: recipes, resetTimesCooked: resetTimesCooked, includeImages: includeImages, tagToAdd: tagForExport) {
                            showShareLink = true
                        }
                        
                    }, label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    })
                    .buttonStyle(.bordered)
                    
                    Button(role: .destructive, action: {
                        showExportOverlay = false
                    }, label: {
                        Label("Cancel", systemImage: "xmark")
                    })
                    .buttonStyle(.bordered)
                    
                }
                .padding(.bottom)
            }
            .overlayVStack()
        }
    }
}

#Preview {
    ExportRecipesOverlay(recipesManager: RecipesManager(), showExportOverlay: .constant(true), recipes: [])
}
