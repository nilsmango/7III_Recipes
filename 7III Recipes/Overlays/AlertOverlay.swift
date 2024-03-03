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
    var showSymbol = true
    var symbolPositive = false
    var padding: Double = 16.0
    
    @State private var offset = CGSize(width: 0, height: 0)
    
    var body: some View {
        if showAlert {
            VStack {
                HStack {
                    if showSymbol {
                        Image(systemName: symbolPositive ? "checkmark.circle" : "exclamationmark.triangle")
                    }
                    Text(text)
                }
                .foregroundStyle(.folderBG)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .padding(padding)
                .background {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundColor(.accentColor)
                        .shadow(color: .gray.opacity(0.2), radius: 10)
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.8)
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                    }
                    .onEnded { _ in
                        withAnimation {
                            offset = CGSize(width: 0, height: 0)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            withAnimation {
                                showAlert = false
                            }
                        }
                    }
            )
            .onTapGesture {
                withAnimation {
                    showAlert = false
                }
            }
            .outsideTap {
                withAnimation {
                    showAlert = false
                }
            }
        }
    }
}



#Preview {
    AlertOverlay(showAlert: .constant(true), text: "A huge amount of text that!", symbolPositive: true)
        .frame(width: 10000, height: 10000)
        .background {
            Color.gray.opacity(0.1)
        }
        
}
