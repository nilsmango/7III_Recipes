//
//  ShakeEffect.swift
//  MDRecipes
//
//  Created by Simon Lang on 17.04.23.
//

import Foundation

import SwiftUI

struct ShakeEffect: AnimatableModifier {
    var shakeNumber: CGFloat = 0

    var animatableData: CGFloat {
        get {
            shakeNumber
        } set {
            shakeNumber = newValue
        }
    }

    func body(content: Content) -> some View {
        content
            .offset(x: sin(shakeNumber * .pi * 2) * 2)
    }
}
