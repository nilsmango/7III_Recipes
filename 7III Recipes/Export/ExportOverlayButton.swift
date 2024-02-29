//
//  ExportOverlayButton.swift
//  7III Recipes
//
//  Created by Simon Lang on 29.02.2024.
//

import SwiftUI

struct ExportOverlayButton: View {
    var onExport: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                onExport()
            }, label: {
                Text("Export Selected Recipes")
            })
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    ExportOverlayButton(onExport: {})
}
