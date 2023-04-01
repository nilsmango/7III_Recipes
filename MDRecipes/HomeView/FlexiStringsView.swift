//
//  TagsView.swift
//  MDRecipes
//
//  Created by Simon Lang on 31.03.23.
//

import SwiftUI

struct FlexiStringsView: View {
    var strings: [String]
    
    var body: some View {
        FlexibleView(
            data: strings,
            spacing: 5,
            alignment: .leading
        ) { string in

                Text(string)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.blue)
                        
                    )
//            }
            
                
        }
    }
}

struct FlexiStringsView_Previews: PreviewProvider {
    static var previews: some View {
        FlexiStringsView(strings: ["#SuckIt", "#motherFucker"])
    }
}
