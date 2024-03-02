//
//  RenameTagVStack.swift
//  7III Recipes
//
//  Created by Simon Lang on 02.03.2024.
//

import SwiftUI

struct RenameTagVStack: View {
    @ObservedObject var recipesManager: RecipesManager
            
    @State private var newTag = ""
    
    var body: some View {
        VStack {
            Text("Rename Tag")
                .font(.headline)
                .padding()
            
            VStack(spacing: 12) {
                Text(recipesManager.tagAlert.renameAlertText)
                
                TextField("#updatedTag", text: $newTag)
                    .tagTextField(text: $newTag, active: true)
            }
            .onAppear {
                newTag = recipesManager.tagAlert.tag
            }
            
            HStack {
                Button(action: {
                    recipesManager.tagAlert.showRenameAlert = false
                    recipesManager.updateTag(oldName: recipesManager.tagAlert.tag, newName: newTag)
                    recipesManager.tagAlert.doneAlertText = "\(recipesManager.tagAlert.tag) was renamed to \(newTag)."
                    recipesManager.tagAlert.showDoneAlert = true
                    
                }, label: {
                    Label("Update", systemImage: "checkmark")
                })
                .buttonStyle(.bordered)
                .disabled(newTag == recipesManager.tagAlert.tag || newTag == "#")
                
                Button(role: .destructive, action: {
                    recipesManager.tagAlert.showRenameAlert = false
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

#Preview {
    RenameTagVStack(recipesManager: RecipesManager())
}
