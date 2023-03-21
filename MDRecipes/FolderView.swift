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
                .foregroundColor(.white)
//                .shadow(radius: 2)
            VStack {
                HStack {
                    Image(systemName: "menucard")
                    Spacer()
                    Text(categoryNumber)
                }
                .font(.title)
                
                
//                .padding()
                HStack {
                    Text(categoryFolder)
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

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        FolderView(categoryFolder: "Desert", categoryNumber: "10")
            .background(.gray)
    }
}
