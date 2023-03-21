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
            MarkdownFile(name: "Recipe 01", content: "# My Favorite Recipe\n\nTotal time: 10 min\n\nCategories: Desert\nHere's my favorite recipe:\n\n- [ ] 2000 eggs 1\n- [ ] Freshly ground black peppers\n- Ingredient 3\n\nEnjoy!"),
            MarkdownFile(name: "Recipe 02", content: "# Title\nSource:\nTags: #important, #awesome\nCategories: Grill, First\nRating: 4/5\nPrep time:\nCook time:\nAdditional time:\nTotal time: 70 min\nServings:\nTimes cooked:\n\n## Ingredients\n- [ ] This\n- [ ] That\n- [ ] Apples\n\n## Directions\n1. Do that\n2. Do another thing\n\n## Notes\n\n## Nutrition Facts\n\n## Images (?)\n![alt image](Recipe Images/chickenbreast.jpg)"),
            MarkdownFile(name: "Recipe 03", content: "# Title\nSource:\nTags: #important, #awesome\nCategories: Grill, Party, Smoking Jack\nRating: 3/5\nPrep time:\nCook time:\nAdditional time:\nTotal time: 1 h\nServings:\nTimes cooked:\n\n## Ingredients\n- [ ] Pears\n- [ ] That\n\n## Directions\n1. Do that\n2. Do another thing\n\n## Notes\n\n## Nutrition Facts\n\n## Images (?)\n![alt image](Recipe Images/honey.jpg)"),
            MarkdownFile(name: "Recipe 04", content: "# Recipe 04\nSource:\nTags: #important, #bad\nCategories: Desert\nRating: 3/5\nPrep time:\nCook time:\nAdditional time:\nTotal time: 60 min\nServings:\nTimes cooked:\n\n## Ingredients\n- [ ] honey\n- [ ] Sausage beans\n- [ ] Milk\n\n## Directions\n1. Do that\n2. Do another thing\n\n## Notes\n\n## Nutrition Facts\n\n## Images (?)\n![alt image](Recipe Images/honeywings.jpg)"),
            MarkdownFile(name: "Zucchinithingy", content: "# Zucchinithingy\n\nCategories: Main Course\nTotal time: 40 min\n## Ingredients\n- [ ] 250g Zucchini\n- [ ] 2 tablespoons olive oil\n- [ ] Hickory salt (smoked salt)\n- [ ] 1 heaped teaspoon dried oregano\n- [ ] 1 tablespoon dried oregano\n- [ ] Approximately 240g spaghetti\n- [ ] Salt\n- [ ] 40g butter\n- [ ] 200ml cream\n- [ ] Freshly ground black pepper\n- [ ] 1 egg\n\nEnjoy!"),
            MarkdownFile(name: "Curry", content: "# Curry\n\nSource:\nTags: #wichtig, #bad\nKategorien: Reisgericht\nRating: 5/5\nPrep time:\nCook time:\nAdditional time:\nTotal time: 40min\nServings:\nTimes cooked:\n\n## Zutaten\n- [ ] 200g rote Linsen\n- [ ] 250ml Kokosmilch\n- [ ] 2 Karotten\n- [ ] 2 Kartoffeln\n- [ ] 20g Koriander\n- [ ] 1 Zwiebel (groß)\n- [ ] 3 Zehen Knoblauch\n- [ ] 1 Chili (rot)\n- [ ] 15g Ingwer\n- [ ] 1 EL Tomatenmark\n- [ ] 4 TL Koriandersaat (gemahlen)\n- [ ] 2 TL Kreuzkümmel (gemahlen)\n- [ ] 2 TL Kurkuma\n- [ ] 2 TL Garam masala Gewürzmischung\n- [ ] 800ml Gemüsebrühe\n- [ ] Salz\n- [ ] Zucker\n- [ ] Zitronensaft\n- [ ] Butter zum Anbraten\n\n## Directions\n1. Take the lime and the coconut\n2. Drink it all up\n3. Call me in the morning\n\nEnjoy!")
            
            
        ]
    }
}
