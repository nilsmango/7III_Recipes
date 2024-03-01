//
//  OutsideTap.swift
//  7III Tap
//
//  Created by Simon Lang on 02.02.2024.
//

import SwiftUI

struct OutsideTap: ViewModifier {
    var onTap: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(0.0)
                .contentShape(Rectangle())
                .onTapGesture {
                    onTap()
                }            
        }
    }
}

extension View {
    func outsideTap(onTap: @escaping () -> Void) -> some View {
        self.modifier(OutsideTap(onTap: onTap))
    }
}
