//
//  FolderView.swift
//  MDRecipes
//
//  Created by Simon Lang on 20.03.23.
//

import SwiftUI

struct FolderView: View {
    var categoryFolder: String
    var categoryNumber: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color("FolderBG"))
//                .shadow(radius: 2)
            VStack {
                HStack {
                    Image(systemName: "menucard")
                    Spacer()
                    Text(categoryNumber)
                }
                .foregroundColor(.blue)
                .font(.title)
                
                HStack {
                    Text(categoryFolder)
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

#Preview {
    FolderView(categoryFolder: "Desert", categoryNumber: "10")
        .background(.gray)
    
}
