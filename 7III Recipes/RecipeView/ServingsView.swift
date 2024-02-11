//
//  ServingsView.swift
//  MDRecipes
//
//  Created by Simon Lang on 31.03.23.
//

import SwiftUI

struct ServingsView: View {
    @Binding var selectedServings: Int
    var body: some View {
        HStack {
            Text("\(selectedServings)")
            Spacer()
            Button(action: {
                if selectedServings > 1 {
                    selectedServings -= 1
                }
                }) {
                Image(systemName: "minus.circle")
            }
            .buttonStyle(.bordered)
            Button(action: {
                selectedServings += 1
            }) {
                Image(systemName: "plus.circle")
            }
            .buttonStyle(.bordered)
        }
    }
}

struct ServingsView_Previews: PreviewProvider {
    static var previews: some View {
        ServingsView(selectedServings: .constant(4))
    }
}
