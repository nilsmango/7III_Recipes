//
//  TagTextField.swift
//  7III Recipes
//
//  Created by Simon Lang on 02.03.2024.
//

import SwiftUI

struct TagTextFieldModifier: ViewModifier {
    @Binding var text: String
    var active: Bool

    func body(content: Content) -> some View {
        content
            .foregroundStyle(active ? .primary : .secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.buttonBG)
            )
            .frame(width: 170)
            .padding(.bottom)
            .onChange(of: text) { newValue in
                var newTag = newValue
                if !newTag.hasPrefix("#") {
                    newTag = "#" + newTag
                }
                text = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
    }
}


extension View {
    func tagTextField(text: Binding<String>, active: Bool) -> some View {
        self.modifier(TagTextFieldModifier(text: text, active: active))
    }
}
