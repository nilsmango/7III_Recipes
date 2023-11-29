//
//  CustomNavBar.swift
//  7III Recipes
//
//  Created by Simon Lang on 29.11.23.
//

import Foundation
import SwiftUI

struct CustomNavBar: ViewModifier {

    init() {
        let design = UIFontDescriptor.SystemDesign.rounded
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
                                         .withDesign(design)!.withSymbolicTraits(.traitBold)!
        // pass size: 0 to UIFont's initializer to use the default font size for .largeTitle
        let font = UIFont.init(descriptor: descriptor, size: 0)
        
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : font]
    }

    func body(content: Content) -> some View {
        content
    }

}

extension View {

    func customNavBar() -> some View {
        self.modifier(CustomNavBar())
    }

}
