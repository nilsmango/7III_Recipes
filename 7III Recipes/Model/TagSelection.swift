//
//  TagSelection.swift
//  7III Recipes
//
//  Created by Simon Lang on 17.02.2024.
//

import Foundation

struct TagSelection: Identifiable, Codable, Hashable {
    var tag: String
    let id: UUID
    
    init(tag: String, id: UUID = UUID()) {
        self.tag = tag
        self.id = id
    }
}
