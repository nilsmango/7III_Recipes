//
//  RecipeSegments.swift
//  MDRecipes
//
//  Created by Simon Lang on 08.04.23.
//

import Foundation

class Importer: ObservableObject {
    
    @Published var recipeSegments = [RecipeSegment]()
    
    
    func reAssignSegment(oldValue: RecipeParts, newValue: RecipeParts) {
        // move the line to the new segment or remove it entirely
            if let oldSegmentIndex = recipeSegments.firstIndex(where: { $0.part == oldValue }) {
                // save the lines
                let lines = recipeSegments[oldSegmentIndex].lines
                // remove the lines
                recipeSegments.remove(at: oldSegmentIndex)
                
                
                    if let newSegmentIndex = recipeSegments.firstIndex(where: { $0.part == newValue }) {
                        // in front if the segment comes after the old segment, append if the new segment comes before the old segment
                        if oldSegmentIndex > newSegmentIndex {
                            recipeSegments[newSegmentIndex].lines.append(contentsOf: lines)
                        } else {
                            recipeSegments[newSegmentIndex].lines.insert(contentsOf: lines, at: 0)
                        }
                        
                    } else {
                        // check if linePart comes before or after the segmentPart in the cases of RecipeParts
                        let allCases = RecipeParts.allCases
                        if let newIndex = allCases.firstIndex(of: newValue),
                           let oldIndex = allCases.firstIndex(of: oldValue) {
                            if oldIndex > newIndex {
                                recipeSegments.insert(RecipeSegment(part: newValue, lines: lines), at: oldSegmentIndex)
                            } else {
                                recipeSegments.insert(RecipeSegment(part: newValue, lines: lines), at: oldSegmentIndex + 1)
                            }
                        }
                    }
            }
        
    }
    
    func reAssignLine(segmentPart: RecipeParts, newLinePart: RecipeParts, line: String) {
        // move the line to the new segment or remove it entirely
            if let segmentIndex = recipeSegments.firstIndex(where: { $0.part == segmentPart }) {
                
                recipeSegments[segmentIndex].lines.removeAll(where: { $0 == line})
                if newLinePart != .remove  {
                    if let newSegmentIndex = recipeSegments.firstIndex(where: { $0.part == newLinePart }) {
                        // in front if the segment comes after the old segment, append if the new segment comes before the old segment
                        if segmentIndex > newSegmentIndex {
                            recipeSegments[newSegmentIndex].lines.append(line)
                        } else {
                            recipeSegments[newSegmentIndex].lines.insert(line, at: 0)
                        }
                        
                    } else {
                        // check if linePart comes before or after the segmentPart in the cases of RecipeParts
                        let allCases = RecipeParts.allCases
                        if let newIndex = allCases.firstIndex(of: newLinePart),
                           let oldIndex = allCases.firstIndex(of: segmentPart) {
                            if oldIndex > newIndex {
                                recipeSegments.insert(RecipeSegment(part: newLinePart, lines: [line]), at: segmentIndex)
                            } else {
                                recipeSegments.insert(RecipeSegment(part: newLinePart, lines: [line]), at: segmentIndex + 1)
                            }
                        }
                    }
        }
            
        }
    }
    
    func removeSegment(_ segment: RecipeSegment) {
        recipeSegments.removeAll(where:  { $0.id == segment.id })
    }
    
    
    
}

