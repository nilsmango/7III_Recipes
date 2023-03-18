//
//  MarkdownFile.swift
//  MDRecipes
//
//  Created by Simon Lang on 16.03.23.
//

import Foundation

struct MarkdownFile: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let content: String
    
    init(id: UUID = UUID(), name: String, content: String) {
        self.id = id
        self.name = name
        self.content = content
    }
}

extension MarkdownFile {
    static var sampleData: [MarkdownFile] {
        [
            MarkdownFile(name: "Recipe 01", content: "# My Favorite Recipe\n\nHere's my favorite recipe:\n\n- Ingredient 1\n- Ingredient 2\n- Ingredient 3\n\nEnjoy!"),
            MarkdownFile(name: "Recipe 02", content: "# Title\nSource:\nTags: #important, #awesome\nCategories: Grill, First\nRating: 4/5\nPrep time:\nCook time:\nAdditional time:\nTotal time:\nServings:\nTimes cooked:\n\n## Ingredients\n- [ ] This\n- [ ] That\n- [ ] Apples\n\n## Directions / Instructions\n1. Do that\n2. Do another thing\n\n## Notes\n\n## Nutrition Facts\n\n## Images (?)\n![alt image](Recipe Images/chickenbreast.jpg)"),
            MarkdownFile(name: "Recipe 03", content: "# Title\nSource:\nTags: #important, #awesome\nCategories: Grill, Party, Smoking Jack\nRating: 3/5\nPrep time:\nCook time:\nAdditional time:\nTotal time:\nServings:\nTimes cooked:\n\n## Ingredients\n- [ ] Pears\n- [ ] That\n\n## Directions / Instructions\n1. Do that\n2. Do another thing\n\n## Notes\n\n## Nutrition Facts\n\n## Images (?)\n![alt image](Recipe Images/honey.jpg)"),
            MarkdownFile(name: "Recipe 04", content: "# Title\nSource:\nTags: #important, #bad\nCategories: Desert\nRating: 3/5\nPrep time:\nCook time:\nAdditional time:\nTotal time:\nServings:\nTimes cooked:\n\n## Ingredients\n- [ ] honey\n- [ ] Sausage beans\n- [ ] Milk\n\n## Directions / Instructions\n1. Do that\n2. Do another thing\n\n## Notes\n\n## Nutrition Facts\n\n## Images (?)\n![alt image](Recipe Images/honeywings.jpg)")
        
        ]
    }
}
