//
//  VisibilityView.swift
//  MDRecipes
//
//  Created by Simon Lang on 23.03.23.
//

import SwiftUI


struct VisibilityView: View {
    @State private var textVisibility: [Bool] = Array(repeating: false, count: 10)
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 40) {
                    LazyVStack {
                        ForEach(0..<5) { index in
                            Text("Text \(index)")
                                .font(.title)
                                .onAppear() {
                                    
                                    textVisibility[index] = true
                                }
                                .onDisappear() {
                                    textVisibility[index] = false
                                }
                        }
                    }
                    ForEach(0..<10) { index in
                        Text(textVisibility[index] ? "Text \(index) yes" : "Text \(index) no")
                            .font(.title)
                    }
                    LazyVStack {
                        ForEach(0..<5) { index in
                            Text("Text \(index + 5)")
                                .font(.title)
                                .onAppear() {
                                    
                                    textVisibility[index + 5] = true
                                }
                                .onDisappear() {
                                    textVisibility[index + 5] = false
                                }
                        }
                    }
                    
                }
            }
        }
    }
}

struct VisibilityView_Previews: PreviewProvider {
    static var previews: some View {
        VisibilityView()
    }
}
