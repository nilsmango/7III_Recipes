//
//  SplashViewAnimation.swift
//  7III Recipes
//
//  Created by Simon Lang on 02.12.23.
//

import SwiftUI

struct SplashViewAnimation: View {
    @Binding var loading: Bool
    
    @Binding var showSplash: Bool
    
    var body: some View {
       
            VStack {
                Spacer()
                Spacer()
                Text(loading ? "Loading Recipes ..." : "Loading Complete!")
                    .foregroundStyle(.blue)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.white)
                    )
                Spacer()
            }
            .background {
                BackgroundAnimation(backgroundColor: Color("SplashBG"))
            }
        
        .onChange(of: loading) { _ in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showSplash = false
//            }
            
        }
        .onTapGesture {
            showSplash = false
        }
//        .ignoresSafeArea(.all)
    }
 
}

#Preview {
    SplashViewAnimation(loading: .constant(true), showSplash: .constant(false))
}
