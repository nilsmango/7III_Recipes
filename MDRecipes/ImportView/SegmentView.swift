//
//  SegmentView.swift
//  MDRecipes
//
//  Created by Simon Lang on 07.04.23.
//

import SwiftUI

struct SegmentView: View {
    @Binding var segment: RecipeSegment
    
    // Edit Mode
    @State private var isWiggling = false
    @State private var paddingActive = false
    
    var body: some View {
        VStack {
            HStack {
               
                    VStack(alignment: .leading) {
                        ForEach(segment.lines, id: \.self) { line in
                            SegmentStackView(segmentPart: segment.part, line: line, isWiggling: isWiggling)
                            .padding(.vertical, paddingActive ? 8 : 0)
                        }
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(segment.part == .unknown ? .red : paddingActive ? .gray : .green)
                            .opacity(paddingActive ? 0.2 : 0.4)

                    }
                    
                
                
                
                if !isWiggling {
                    Spacer()
                    
                    VStack {
                            HStack {
                                Image(systemName: segment.part == .unknown ? "xmark" : "checkmark")
                                    .padding(.leading, 5)
                                    .padding(.trailing, -10)
                                Picker("Select a Recipe Part", selection: $segment.part) {
                                                ForEach(RecipeParts.allCases, id: \.self) { recipePart in
                                                    Text(Parser.getRecipePartName(for: recipePart))
                                                }
                                            }
                            }
                            .tint(.primary)

                        if segment.lines.count > 1 {
                            Button {
                                withAnimation() {
                                    paddingActive.toggle()
                                }
                                isWiggling.toggle()
                                
                                             
                            } label: {
                                Label("Edit", systemImage: "arrow.triangle.swap")
                            }
                            .buttonStyle(.bordered)
                        }
                            
                            Button(role: .destructive) {
                                //
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                            .buttonStyle(.bordered)

                    }
                }
                
                
            }
            
            
            if isWiggling {
                Button {
                    withAnimation() {
                        paddingActive.toggle()
                    }
                    isWiggling.toggle()
                    
                                 
                } label: {
                    Label("Done", systemImage: "arrow.triangle.swap")
                }
                .buttonStyle(.bordered)
            }
            
        }
        .padding()
        
    }
}

struct SegmentView_Previews: PreviewProvider {
    static var previews: some View {

            SegmentView(segment: .constant(RecipeSegment(part: .cookTime, lines: ["Ingredients", "500 g sugar", "20 black peas"])))
                .frame(height: 500)
            
        
    }
}
