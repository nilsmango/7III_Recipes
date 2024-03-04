//
//  RecipeImageView.swift
//  MDRecipes
//
//  Created by Simon Lang on 12.04.23.
//

import SwiftUI

struct RecipeImageView: View {
    let imagePath: String
    let caption: String
    var body: some View {
        LazyVStack(alignment: .leading) {
            if let image = UIImage(contentsOfFile: imagePath) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 25.0))
                    } else {
                        Text("Error loading image")
                    }
            
            Text(caption)
        }
    }
}

#Preview {
    RecipeImageView(imagePath: "/Users/simxn/Downloads/WhatsApp Image 2024-01-03 at 10.40.04.jpeg", caption: "Captioning the shit out of this.")
}
