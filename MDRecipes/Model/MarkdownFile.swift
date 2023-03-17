//
//  MarkdownFile.swift
//  MDRecipes
//
//  Created by Simon Lang on 16.03.23.
//

import Foundation

struct MarkdownFile: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let content: String
}

extension MarkdownFile {
    static var sampleData: [MarkdownFile] {
        [
            MarkdownFile(name: "Recipe 01", content: "# My Favorite Recipe\n\nHere's my favorite recipe:\n\n- Ingredient 1\n- Ingredient 2\n- Ingredient 3\n\nEnjoy!"),
            MarkdownFile(name: "Recipe 02", content: "# Title\nSource:\nTags: #important, #awesome\nCategories: Grill, Party\nRating: 4/5\nPrep time:\nCook time:\nAdditional time:\nTotal time:\nServings:\nTimes cooked:\n\n## Ingredients\n- [ ] This\n- [ ] That\n\n## Directions / Instructions\n1. Do that\n2. Do another thing\n\n## Notes\n\n## Nutrition Facts\n\n## Images (?)\n![alt image](Recipe Images/chickenbreast.jpg)"),
            MarkdownFile(name: "Recipe 03", content: "# Title\nSource:\nTags: #important, #awesome\nCategories: Grill, Party\nRating: 4/5\nPrep time:\nCook time:\nAdditional time:\nTotal time:\nServings:\nTimes cooked:\n\n## Ingredients\n- [ ] This\n- [ ] That\n\n## Directions / Instructions\n1. Do that\n2. Do another thing\n\n## Notes\n\n## Nutrition Facts\n\n## Images (?)\n![alt image](Recipe Images/honey.jpg)")
        
        ]
    }
}
