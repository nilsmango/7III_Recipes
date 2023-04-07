//
//  SegmentStackView.swift
//  MDRecipes
//
//  Created by Simon Lang on 07.04.23.
//

import SwiftUI

struct SegmentStackView: View {
    @State private var linePart: RecipeParts = .notes
    var segmentPart: RecipeParts
    var line: String
    var isWiggling: Bool
    
    var body: some View {
        HStack {
            Text(line)
            if isWiggling {
                Spacer()
                HStack {
                    Image(systemName: segmentPart == .unknown ? "xmark" : "checkmark")
                        .padding(.leading, 5)
                        .padding(.trailing, -10)
                    Picker("Select a Recipe Part", selection: $linePart) {
                                    ForEach(RecipeParts.allCases, id: \.self) { recipePart in
                                        Text(Parser.getRecipePartName(for: recipePart))
                                    }
                                }
                }
                .tint(.primary)
                .onAppear {
                    linePart = segmentPart
                }
            }
            
        }
    }
}

struct SegmentStackView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentStackView(segmentPart: .cookTime, line: "Cook Time: 2 h", isWiggling: true)
    }
}
