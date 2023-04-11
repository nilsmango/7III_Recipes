//
//  ImageDetailView.swift
//  MDRecipes
//
//  Created by Simon Lang on 11.04.23.
//

import SwiftUI

struct ImageDetailView: View {
    let image: Image
    @State private var description = ""
    
    
    var body: some View {
        VStack {
            image
                .resizable()
                .scaledToFit()
            
            TextField("Your description ...", text: $description, axis: .vertical)
                .padding(5)
                .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.gray)
                    .opacity(0.1)
                )
        }
    }
}

struct ImageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ImageDetailView(image: Image(systemName: "photo"))
    }
}
