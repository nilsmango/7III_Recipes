//
//  FolderView.swift
//  MDRecipes
//
//  Created by Simon Lang on 20.03.23.
//

import SwiftUI

struct RandomRecipeView: View {

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.white)
//                .shadow(radius: 2)
            VStack {
                HStack {
                    Image(systemName: "questionmark.app.dashed")
                    Spacer()
                    Text("1")
                        .opacity(0)
                }
                .font(.title)
                
                
//                .padding()
                HStack {
                    Text("Random Recipe")
                    Spacer()
                }
//                .font(.title2)
                .foregroundColor(.secondary)
                .padding(.top, 1)
                
            }
            .fontWeight(.bold)
            .fontDesign(.rounded)
            .padding()
            
        }
        
//        .padding()
//        .frame(width: 140, height: 90)
        
        
    }
}

struct RandomRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RandomRecipeView()
            .background(.gray)
    }
}
