//
//  TagsContextMenu.swift
//  7III Recipes
//
//  Created by Simon Lang on 02.03.2024.
//

import SwiftUI

struct TagsContextMenu: View {
    @ObservedObject var recipesManager: RecipesManager

    var tag: String

    var body: some View {
        
        // rename Tag
        Button(action: {
            recipesManager.tagAlert.tag = tag
            let recipesCount = recipesManager.findNumberForTag(tag: tag)
            recipesManager.tagAlert.renameAlertText = ("\(tag) will get renamed in \(recipesCount) recipes.")
            recipesManager.tagAlert.showRenameAlert = true
        }, label: {
            Label("Rename Tag", systemImage: "pencil")
        })
        
        // delete tag
        Button(role: .destructive, action: {
            let recipesCount = recipesManager.deleteTag(tag: tag)
            recipesManager.tagAlert.doneAlertText = "Removed \(tag) from \(recipesCount) recipes."
            recipesManager.tagAlert.showDoneAlert = true
        }, label: {
            Label("Delete Tag", systemImage: "trash")
        })
        
        
    }
}

#Preview {
    TagsContextMenu(recipesManager: RecipesManager(), tag: "#bitch")
}
