//
//  SegmentsImportView.swift
//  MDRecipes
//
//  Created by Simon Lang on 07.04.23.
//

import SwiftUI

struct SegmentsImportView: View {
    @ObservedObject var importer: Importer

    var body: some View {
        ScrollView {
            
                
            VStack() {
                Text("Assign the Segments")
                ForEach(importer.recipeSegments) { segment in
                        SegmentView(importer: importer, segment: segment)
                    }
                }
            .padding(.horizontal)
            .scrollContentBackground(.hidden)
        }
        .background(
            .gray
            .opacity(0.1)
        )
        .background(ignoresSafeAreaEdges: .all)
        
        
    }
    
}

struct SegmentsImportView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentsImportView(importer: Importer())
    }
}
