//
//  SplashViewAnimation.swift
//  7III Recipes
//
//  Created by Simon Lang on 02.12.23.
//

import SwiftUI

struct BackgroundAnimation: View {
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    
    let backgroundColor: Color
    
    @State var logoOffset = CGSize(width: 0, height: 0)
    
    @State private var rotationAmount: Double = 0.0
    
    @State private var fallingImages: [Image] = ["CookThing", "Knife", "Spoon", "Wallholz", "Fork"].map { Image($0) }
    
    @State private var imageOffsets: [CGSize] = Array(repeating: CGSize(width: -300,height: 0), count: 5).map( { _ in CGSize(width: (Bool.random() ? 1.0 : -1.0) * (0.7 * UIScreen.main.bounds.width),height: CGFloat.random(in: -0.5...0.5) * UIScreen.main.bounds.height) })
    
    @State private var rotation: [Double] = Array(repeating: 0.0, count: 5)

    
    var body: some View {
        ZStack {
            backgroundColor
            
            Image("AppLogo")
//                .resizable()
//                .renderingMode(.original)
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 85)
                .rotationEffect(.degrees(rotationAmount))
                .offset(logoOffset)
                .onAppear {
                    withAnimation(Animation.easeIn(duration: 50).repeatForever(autoreverses: false).delay(0)) {
                        let randomDirection = Bool.random() ? -1 : 1
                        rotationAmount = Double(randomDirection * 360)
                    }
                    withAnimation(Animation.easeIn(duration: 80)) {
                        logoOffset = CGSize(width: (Bool.random() ? -2 : 2) * screenWidth, height: (Bool.random() ? -2 : 2)  * screenHeight)
                    }
                }
            
            ForEach(0..<fallingImages.count, id: \.self) { index in
                fallingImages[index]
                    .rotationEffect(.degrees(rotation[index]))
                    .offset(imageOffsets[index])
                    .onAppear {
                        withAnimation(Animation.linear(duration: Double.random(in: 0.8...8.0)).repeatForever(autoreverses: false)) {
                            let randomDirection = Bool.random() ? -1 : 1
                            rotation[index] = Double(randomDirection * 360)
                        }
                        withAnimation(Animation.linear(duration: Double.random(in: 10...50.0)).delay(Double.random(in: 0...6.0))) {
                            imageOffsets[index] = CGSize(width: imageOffsets[index].width * -1.0, height: CGFloat.random(in: -2...2) * screenHeight)
                        }
                    }
            }
        }
        
        .ignoresSafeArea(.all)
        .frame(width: screenWidth)
    }
 
}

#Preview {
    BackgroundAnimation(backgroundColor: Color("SplashBG"))
}
