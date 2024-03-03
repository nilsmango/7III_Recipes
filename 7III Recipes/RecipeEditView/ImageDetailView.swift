//
//  ImageDetailView.swift
//  MDRecipes
//
//  Created by Simon Lang on 11.04.23.
//

import SwiftUI

struct ImageDetailView: View {
    let image: Image
    @Binding var caption: String
    
    
    var body: some View {
        VStack {
            image
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 25.0))
            
            TextField("Your caption ...", text: $caption, axis: .vertical)
                .padding(5)
                .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.gray)
                    .opacity(0.1)
                )
        }
    }
}

#Preview {
    ImageDetailView(image: Image(systemName: "photo"), caption: .constant("Some caption"))
}
