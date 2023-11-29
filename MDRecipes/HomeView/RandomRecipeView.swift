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
                .foregroundColor(Color("FolderBG"))
//                .shadow(radius: 2)
            VStack {
                HStack {
                    Image(systemName: "questionmark.app.dashed")
                    Spacer()
                    Text("1")
                        .opacity(0)
                }
                .font(.title)

                HStack {
                    Text("Random Recipe")
                    Spacer()
                }
                .foregroundColor(.primary)
                .padding(.top, 1)
                
            }
            .fontWeight(.bold)
            .fontDesign(.rounded)
            .padding()
            
        }
        
        
        
    }
}

struct RandomRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RandomRecipeView()
            .background(.gray)
    }
}
