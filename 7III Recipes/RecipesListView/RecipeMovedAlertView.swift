//
//  RecipeMovedAlertView.swift
//  MDRecipes
//
//  Created by Simon Lang on 17.11.23.
//

import SwiftUI

struct RecipeMovedAlertView: View {
    @Binding var recipeMovedAlert: RecipeMovedAlert
    
    var body: some View {
        if recipeMovedAlert.showAlert {
            HStack {
                    
                    Text("The recipe \"\(recipeMovedAlert.recipeName)\" was moved to category \"\(recipeMovedAlert.movedToCategory)\".")
                        
                        .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color("CustomLightGray"))
//                        .background(.ultraThinMaterial)
                }
                .onTapGesture {
                    recipeMovedAlert.showAlert = false
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        recipeMovedAlert.showAlert = false
                    }
                }
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width * 0.8)
        }
        
    }
}

#Preview {
    RecipeMovedAlertView(recipeMovedAlert: .constant(RecipeMovedAlert(showAlert: true, recipeName: "Älplermarcroenen", movedToCategory: "Nachtisch")))
}
