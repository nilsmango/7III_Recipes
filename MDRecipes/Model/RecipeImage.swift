//
//  RecipeImage.swift
//  MDRecipes
//
//  Created by Simon Lang on 11.04.23.
//

import Foundation
import SwiftUI

struct RecipeImage: Identifiable, Codable {
    var image: Image
    var description: String
    
    let id: UUID
    
    enum CodingKeys: String, CodingKey {
        case imageData, description, id
    }
    
    init(image: Image, description: String, id: UUID = UUID()) {
        self.image = image
        self.description = description
        self.id = id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let imageData = try container.decode(Data.self, forKey: .imageData)
        let uiImage = UIImage(data: imageData)!
        image = Image(uiImage: uiImage)
        description = try container.decode(String.self, forKey: .description)
        id = try container.decode(UUID.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let uiImage = image.asUIImage()
        let imageData = uiImage.pngData()!
        try container.encode(imageData, forKey: .imageData)
        try container.encode(description, forKey: .description)
        try container.encode(id, forKey: .id)
    }
}

extension Image {
    func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        let size = view?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = UIColor.clear
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
