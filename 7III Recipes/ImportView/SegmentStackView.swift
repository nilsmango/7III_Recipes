//
//  SegmentStackView.swift
//  MDRecipes
//
//  Created by Simon Lang on 07.04.23.
//

import SwiftUI

struct SegmentStackView: View {
    @ObservedObject var importer: Importer
    
    @State private var newLinePart: RecipeParts = .notes
    var segmentPart: RecipeParts
    var line: String
    var isWiggling: Bool
    
    var body: some View {
        HStack {
            Text(line)
            if isWiggling {
                Spacer()
                HStack {
                    if newLinePart == .remove {
                        Image(systemName: "trash")
                            .padding(.leading, 5)
                            .padding(.trailing, -10)
                    } else {
                        Image(systemName: newLinePart == .unknown ? "xmark" : "checkmark")
                            .padding(.leading, 5)
                            .padding(.trailing, -10)
                    }
                    
                    Picker("Select a Recipe Part", selection: $newLinePart) {
                                    ForEach(RecipeParts.allCases, id: \.self) { recipePart in
                                        Text(Parser.getRecipePartName(for: recipePart))
                                    }
                                }
                }
                .tint(.primary)
                .onAppear {
                    newLinePart = segmentPart
                }
                .onDisappear {
                    if newLinePart != segmentPart {
                        importer.reAssignLine(segmentPart: segmentPart, newLinePart: newLinePart, line: line)
                    }
                }
            }
            
        }
    }
}

struct SegmentStackView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentStackView(importer: Importer(), segmentPart: .cookTime, line: "Cook Time: 2 h", isWiggling: true)
    }
}
