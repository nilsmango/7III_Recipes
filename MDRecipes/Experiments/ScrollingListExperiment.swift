//
//  ScrollingListExperiment.swift
//  MDRecipes
//
//  Created by Simon Lang on 24.03.23.
//

import SwiftUI

struct ScrollingListExperiment: View {
    @State private var scrollToId: Int? = nil
        
        var body: some View {
            VStack {
                Button("Scroll to ID 15") {
                    scrollToId = 25
                }
                ScrollViewReader { scrollView in
                    List {
                        ForEach(0..<100) { id in
                            Text("ID \(id)")
                                .id(id)
                        }
                    }
                    .onChange(of: scrollToId) { id in
                        if let id = id {
                            withAnimation {
                                scrollView.scrollTo(id)
                            }
                            scrollToId = nil
                        }
                    }
                }
            }
        }
    }

struct ScrollingListExperiment_Previews: PreviewProvider {
    static var previews: some View {
        ScrollingListExperiment()
    }
}
