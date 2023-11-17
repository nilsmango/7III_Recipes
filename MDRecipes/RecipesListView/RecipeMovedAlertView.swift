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
                VStack {
                    Text("The recipe \"\(recipeMovedAlert.recipeName)\" was moved to \"\(recipeMovedAlert.movedToCategory)\".")
                        
                    .foregroundColor(Color(.systemBackground))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    
                            Button {
                                
                                recipeMovedAlert.showAlert = false
                            } label: {
                                Text("OK")
                            }
                      
                    .buttonStyle(.bordered)
                    .tint(Color(.systemBackground))
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10)
//                        .foregroundColor(.gray)
                        .background(.ultraThinMaterial)
                }
            }
            .padding()
        }
        
    }
}

#Preview {
    RecipeMovedAlertView(recipeMovedAlert: .constant(RecipeMovedAlert(showAlert: true, recipeName: "Älplermarcroenen", movedToCategory: "Nachtisch")))
}
