//
//  RecipeSegments.swift
//  MDRecipes
//
//  Created by Simon Lang on 08.04.23.
//

import Foundation

class Importer: ObservableObject {
    
    @Published var recipeSegments = [RecipeSegment]()
    
    /// reassigning segments returns true if we have more than one line and need to check if there is a title in there
    func reAssignSegment(oldValue: RecipeParts, newValue: RecipeParts, id: UUID) -> Bool {
        print("Reassigning segment")
        // move the line to the new segment or remove it entirely
            if let oldSegmentIndex = recipeSegments.firstIndex(where: { $0.id == id }) {
                // save the lines
                let lines = recipeSegments[oldSegmentIndex].lines
                
                // remove the segment
                recipeSegments.remove(at: oldSegmentIndex)
                
                // check if there already is a segment with the new segment part
                    if let knownSegmentIndex = recipeSegments.firstIndex(where: { $0.part == newValue }) {
                        // in front if the segment comes after the old segment, append if the new segment comes before the old segment
                        if oldSegmentIndex > knownSegmentIndex {
                            recipeSegments[knownSegmentIndex].lines.append(contentsOf: lines)
                        } else {
                            recipeSegments[knownSegmentIndex].lines.insert(contentsOf: lines, at: 0)
                        }
                    // if the new part is not already in the recipeSegments
                    } else {
                        // just insert it back where we had it
                        recipeSegments.insert(RecipeSegment(part: newValue, lines: lines), at: oldSegmentIndex)
                    }
                
                // check if there are more than one lines now
                if lines.count > 1 {
                    return true
                }
            }
        return false
    }
    
    func reAssignLine(segmentPart: RecipeParts, newLinePart: RecipeParts, line: String) {
        // find the segment index
            if let segmentIndex = recipeSegments.firstIndex(where: { $0.part == segmentPart }) {
                // check if we find our line there
                if let lineIndexInFirstSegment = recipeSegments[segmentIndex].lines.firstIndex(where: { $0 == line }) {
                    recipeSegments[segmentIndex].lines.remove(at: lineIndexInFirstSegment)
                } else {
                    // find the next segment
                    if let nextSegmentIndex = recipeSegments.lastIndex(where: { $0.part == segmentPart }) {
                        // check if we find our line there
                        if let lineIndexInSecondSegment = recipeSegments[nextSegmentIndex].lines.firstIndex(where: { $0 == line }) {
                            recipeSegments[nextSegmentIndex].lines.remove(at: lineIndexInSecondSegment)
                        } else {
                            print("couldn't find line in last index")
                            return
                        }
                    } else {
                        print("couldn't find a last index of segment part")
                        return
                    }
                }
                    
                    if newLinePart != .remove  {
                        // find if the part already has lines
                        if let newSegmentIndex = recipeSegments.firstIndex(where: { $0.part == newLinePart }) {
                            // in front if the segment comes after the old segment, append if the new segment comes before the old segment
                            if segmentIndex > newSegmentIndex {
                                recipeSegments[newSegmentIndex].lines.append(line)
                            } else {
                                recipeSegments[newSegmentIndex].lines.insert(line, at: 0)
                            }
                        
                        } else {
                            // just add the line after or before the other lines of that segment.
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
    
    func removeLineFromSegment(segmentPart: RecipeParts, line: String) {
        // find the segment index
        if let segmentIndex = recipeSegments.firstIndex(where: { $0.part == segmentPart }) {
            // find the line
            if let lineIndex = recipeSegments[segmentIndex].lines.firstIndex(where: { $0 == line }) {
                // remove the line
                recipeSegments[segmentIndex].lines.remove(at: lineIndex)
                // add the line to the title lines we don't show
                recipeSegments[segmentIndex].titleLineWeDontShow.append(line)
            }
        }
        
    }
    
}

