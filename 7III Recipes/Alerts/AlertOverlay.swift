//
//  AlertOverlay.swift
//  7III Recipes
//
//  Created by Simon Lang on 12.02.2024.
//

import SwiftUI

struct AlertOverlay: View {
    
    @Binding var showAlert: Bool
    
    var text: String
    var showSymbol: Bool = true
    var symbolPositive = false
    var padding: Double = 16.0
    
    var body: some View {
        if showAlert {
            VStack {
                HStack {
                    if showSymbol {
                        Image(systemName: symbolPositive ? "checkmark" : "exclamationmark.triangle")
                    }
                    Text(text)
                }
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .padding(padding)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.folderBG)
                    //                        .background(.ultraThinMaterial)
                }
                                
            }
            .frame(width: UIScreen.main.bounds.width * 0.8)
            

            .onTapGesture {
                showAlert = false
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    showAlert = false
                }
            }
        }
        
    }
}



#Preview {
    AlertOverlay(showAlert: .constant(true), text: "Cute Alert!")
        .frame(width: 10000, height: 10000)
        .background {
            Color.gray.opacity(0.1)
        }
        
}
