//
//  OverlayVStackModifier.swift
//  7III Tap
//
//  Created by Simon Lang on 01.02.2024.
//

import SwiftUI

struct OverlayVStackModifier: ViewModifier {
    var overlayWidth: Double

    func body(content: Content) -> some View {
        VStack {
            content
        }
        .frame(maxWidth: overlayWidth)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 25)
                .foregroundStyle(.folderBG)
                .shadow(color: .gray.opacity(0.2), radius: 10)
        }
    }
}

extension View {
    func overlayVStack(overlayWidth: Double = UIScreen.main.bounds.width * 0.8) -> some View {
        self.modifier(OverlayVStackModifier(overlayWidth: overlayWidth))
    }
}
