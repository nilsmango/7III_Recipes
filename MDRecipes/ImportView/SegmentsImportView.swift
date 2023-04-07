//
//  SegmentsImportView.swift
//  MDRecipes
//
//  Created by Simon Lang on 07.04.23.
//

import SwiftUI

struct SegmentsImportView: View {
    
    
    @State var recipeSegments: [RecipeSegment] = [RecipeSegment(part: .title, lines: ["Recipe Title"]), RecipeSegment(part: .servings, lines: ["Serves 4"]), RecipeSegment(part: .totalTime, lines: ["Total time: 1 h"]), RecipeSegment(part: .ingredients, lines: ["Ingredients", "500 g sugar", "20 black peas"]), RecipeSegment(part: .directions, lines: ["Instructions", "1. Take the sugar and make it wet.", "2. Wait for 10 Min", "3. Take the peas and let soak. Wait another few hours, then you might be finished.", "4. Once you think you are done.", "You might be finished."]), RecipeSegment(part: .notes, lines: ["Notes", "Cooking can be dangerous"]), RecipeSegment(part: .unknown, lines: ["Misc: We don't know what the fuck we are doing"])]
    
    var body: some View {
        ScrollView {
            
                
            VStack() {
                    ForEach($recipeSegments) { segment in
                        SegmentView(segment: segment)
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
        SegmentsImportView()
    }
}
