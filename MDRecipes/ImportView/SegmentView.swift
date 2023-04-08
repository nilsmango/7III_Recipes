//
//  SegmentView.swift
//  MDRecipes
//
//  Created by Simon Lang on 07.04.23.
//

import SwiftUI

struct SegmentView: View {
    @ObservedObject var importer: Importer
    
    var segment: RecipeSegment
    
    @State private var selectedPart: RecipeParts = .unknown
    
    // Edit Mode
    @State private var isWiggling = false
    @State private var paddingActive = false
    
    var body: some View {
        VStack {
            HStack {
               
                    VStack(alignment: .leading) {
                        ForEach(segment.lines, id: \.self) { line in
                            SegmentStackView(importer: importer, segmentPart: segment.part, line: line, isWiggling: isWiggling)
                            .padding(.vertical, paddingActive ? 8 : 0)
                        }
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(selectedPart == .unknown ? .red : paddingActive ? .gray : .green)
                            .opacity(paddingActive ? 0.2 : 0.4)

                    }
                    
                if !isWiggling {
                    Spacer()
                    
                    VStack {
                            HStack {
                                Image(systemName: selectedPart == .unknown || selectedPart == .remove ? selectedPart == .remove ? "trash" : "xmark" : "checkmark")
                                    .padding(.leading, 5)
                                    .padding(.trailing, -10)
                                Picker("Select a Recipe Part", selection: $selectedPart) {
                                    ForEach(RecipeParts.allCases, id: \.self) { recipePart in
                                        if recipePart != .remove {
                                            Text(Parser.getRecipePartName(for: recipePart))
                                        }
                                                }
                                            }
                                
                            }
                            .tint(.primary)
                            .onAppear {
                                selectedPart = segment.part
                            }
                            .onChange(of: selectedPart) { [oldValue = selectedPart] newValue in
                                // This is to check if it's not the change on appear from above
                                if oldValue == segment.part {
                                    importer.reAssignSegment(oldValue: oldValue, newValue: newValue)
                                }
                            }
                        
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
                                withAnimation {
                                    importer.removeSegment(segment)
                                }
                                
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
                    Label("Done", systemImage: "checkmark")
                }
                .buttonStyle(.bordered)
            }
            
        }
        .padding()
        
    }
}

struct SegmentView_Previews: PreviewProvider {
    static var previews: some View {

        SegmentView(importer: Importer(), segment: RecipeSegment(part: .cookTime, lines: ["Ingredients", "500 g sugar", "20 black peas"]))
                .frame(height: 500)
            
        
    }
}
