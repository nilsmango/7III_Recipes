//
//  ExportLinkOverlay.swift
//  7III Recipes
//
//  Created by Simon Lang on 29.02.2024.
//

import SwiftUI

struct ExportLinkOverlay: View {
    var showShareLink: Bool
    var item: URL
    
    var exit: () -> Void
    
    var body: some View {
        VStack {
            Text(showShareLink ? "Share Recipes" : "Copying Recipes...")
                .font(.headline)
                .padding()
            HStack {
                ShareLink(item: item) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
                
                Button(role: .destructive, action: {
                    exit()
                }, label: {
                    Label("Exit", systemImage: "xmark")
                })
                .buttonStyle(.bordered)
            }
            .disabled(!showShareLink)
            .padding(.bottom)
        }
        .overlayVStack()
    }
}

#Preview {
    ExportLinkOverlay(showShareLink: false, item: URL(string: "https://nilsmango.ch")!, exit: {})
}
