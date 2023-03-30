//
//  ServingsCookedEditView.swift
//  MDRecipes
//
//  Created by Simon Lang on 30.03.23.
//

import SwiftUI

struct ServingsCookedEditView: View {
    @Binding var servings: Int
    @Binding var timesCooked: Int
    
    var body: some View {
        HStack {
            Text("Servings: \(servings)")
            Spacer()
            Button(action: {
                if servings > 1 {
                    servings -= 1
                }
                
            }) {
                Image(systemName: "minus.circle")
            }
            .buttonStyle(.bordered)
            Button(action: {
                servings += 1
            }) {
                Image(systemName: "plus.circle")
            }
            .buttonStyle(.bordered)
        }
    
    
    HStack {
        Text("Times cooked: \(timesCooked)")
        Spacer()
        Button(action: {
            if timesCooked > 0 {
                timesCooked -= 1
            }
            
        }) {
            Image(systemName: "minus.circle")
        }
        .buttonStyle(.bordered)
        Button(action: {
            timesCooked += 1
        }) {
            Image(systemName: "plus.circle")
        }
        .buttonStyle(.bordered)
    }
    }
}

struct ServingsCookedEditView_Previews: PreviewProvider {
    static var previews: some View {
        ServingsCookedEditView(servings: .constant(3), timesCooked: .constant(2))
    }
}
