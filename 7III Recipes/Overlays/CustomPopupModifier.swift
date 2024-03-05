//
//  CustomPopupModifier.swift
//  7III Recipes
//
//  Created by Simon Lang on 29.02.2024.
//


import SwiftUI

struct CustomPopupModifier<PopupContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var popupContent: () -> PopupContent
    
    @State private var offsetY: CGFloat = 0
        
    func body(content: Content) -> some View {
        
            ZStack {
                
                content
                
                if isPresented {
                    
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(0.0)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isPresented = false
                        }
                }
                
                VStack {
                    Spacer()
                    
                    popupContent()
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.folderBG)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.75)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .shadow(color: .gray.opacity(0.2), radius: 10)
                        .offset(y: isPresented ? 0 : 200.0)
                        .animation(.default, value: isPresented)
                        .offset(y: offsetY)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    offsetY = gesture.translation.height
                                }
                                .onEnded { _ in
                                    isPresented = false
                                    withAnimation {
                                        offsetY = 0
                                    }
                                }
                        )
                        .onTapGesture {
                            isPresented = false
                        }
                }

            }
    }
}

extension View {
    func customPopup<Content: View>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View {
        self.modifier(CustomPopupModifier(isPresented: isPresented, popupContent: content))
    }
}
