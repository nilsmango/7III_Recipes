//
//  AboutView.swift
//  7III Recipes
//
//  Created by Simon Lang on 05.12.23.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Text("""
                This is about us.
                Add instructions for saving recipes and recovering or finding the recipes in the "On my iPhone" folder.
                """)
        }
        
        .background {
            BackgroundAnimation(backgroundColor: Color(.gray).opacity(0.1), foregroundColor: .blue)
        }
        .navigationTitle("About")
        
        
    }
}

#Preview {
    AboutView()
}
