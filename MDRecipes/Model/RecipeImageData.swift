//
//  RecipeImage.swift
//  MDRecipes
//
//  Created by Simon Lang on 11.04.23.
//

import Foundation
import UIKit

struct RecipeImageData: Identifiable {
    var image: UIImage
    var caption: String
    var isOldImage: Bool
    
    let id: UUID
    
    init(image: UIImage, caption: String, isOldImage: Bool, id: UUID = UUID()) {
        self.image = image
        self.caption = caption
        self.isOldImage = isOldImage
        self.id = id
    }
}


