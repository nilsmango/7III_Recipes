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
                    
                    Text("The recipe \"\(recipeMovedAlert.recipeName)\" was moved to category \"\(recipeMovedAlert.movedToCategory)\".")
                        
                    .foregroundColor(Color(.systemBackground))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    
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
            .frame(width: UIScreen.main.bounds.width * 0.8)
        }
        
    }
}

#Preview {
    RecipeMovedAlertView(recipeMovedAlert: .constant(RecipeMovedAlert(showAlert: true, recipeName: "Älplermarcroenen", movedToCategory: "Nachtisch")))
}
