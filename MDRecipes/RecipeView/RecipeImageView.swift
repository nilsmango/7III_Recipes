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
        VStack {
            if let image = UIImage(contentsOfFile: imagePath) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Text("Error loading image")
                            .onAppear {
                                print(imagePath)
                            }
                    }
            Text(caption)
        }
    }
}

struct RecipeImageView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeImageView(imagePath: "/Users/simxn/Downloads/71zsGsx7cJL.jpg", caption: "Captioning the shit out of this.")
    }
}
