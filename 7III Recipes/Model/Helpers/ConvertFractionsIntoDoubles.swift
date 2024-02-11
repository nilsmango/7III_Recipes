//
//  ConvertFractionsIntoDoubles.swift
//  MDRecipes
//
//  Created by Simon Lang on 02.04.23.
//

import Foundation

/// A function that finds all kinds of fractions and returns a double value in string.
/// Even works with unicode and mixed values.
func convertFractionToDouble(_ input: String) -> String {
    let fractionPattern = "\\d+\\s+\\d+/\\d+|\\d+/\\d+|\\d+\\.\\d+|\\d+½|\\d+⅓|\\d+⅔|\\d+¼|\\d+¾|half|one-half|one-third|two-thirds|one-fourth|two-fourths|three-fourths" // regular expression pattern to match fractions in various formats
    
    // Find all fractions in the input string
    let regex = try! NSRegularExpression(pattern: fractionPattern)
    let matches = regex.matches(in: input, range: NSRange(input.startIndex..., in: input))
    
    // Replace each fraction with its corresponding double value
    var result = input
    for match in matches.reversed() {
        let range = match.range
        if let fractionRange = Range(range, in: input) {
            let fractionString = input[fractionRange]
            if let doubleValue = getDoubleValue(from: String(fractionString)) {
                let doubleString = String(format: "%.2f", doubleValue)
                result.replaceSubrange(fractionRange, with: doubleString)
            }
        }
    }
    return result
}

private func getDoubleValue(from fractionString: String) -> Double? {
    let fractionComponents = fractionString.components(separatedBy: CharacterSet(charactersIn: " ,"))
    var numerator: Double = 0.0
    var denominator: Double = 1.0
    for component in fractionComponents {
        if let fractionValue = getFractionValue(from: component) {
            numerator = numerator * denominator + fractionValue.0
            denominator *= fractionValue.1
        }
    }
    return numerator / denominator
}

private func getFractionValue(from fractionString: String) -> (Double, Double)? {
    if let unicodeScalar = fractionString.unicodeScalars.first, let fractionValue = getUnicodeFractionValue(from: unicodeScalar) {
        return fractionValue
    }
    
    let spelledOutWords = ["half" : (1.0, 2.0), "one-half": (1.0, 2.0), "one-third": (1.0, 3.0), "two-thirds": (2.0, 3.0), "one-fourth": (1.0, 4.0), "two-fourths": (2.0, 4.0), "three-fourths": (3.0, 4.0)]
    if let spelledOutValue = spelledOutWords[fractionString] {
        return spelledOutValue
    }
    
    let mixedComponents = fractionString.components(separatedBy: CharacterSet(charactersIn: " ,"))
    if mixedComponents.count == 2,
       let wholeNumber = Double(mixedComponents[0]),
       let fractionValue = getFractionValue(from: mixedComponents[1]) {
        return (wholeNumber.sign == .minus ? wholeNumber - fractionValue.0 / fractionValue.1 : wholeNumber + fractionValue.0 / fractionValue.1, 1.0)
    }
    
    let fractionComponents = fractionString.components(separatedBy: "/")
    if fractionComponents.count == 2,
       let numerator = Double(fractionComponents[0]),
       let denominator = Double(fractionComponents[1]) {
        return (numerator, denominator)
    }
    
    if let decimalValue = Double(fractionString) {
        return (decimalValue, 1.0)
    }
    
    return nil
}

private func getUnicodeFractionValue(from unicodeScalar: Unicode.Scalar) -> (Double, Double)? {
    switch unicodeScalar {
    case "½":
        return (1, 2)
    case "⅓":
        return (1, 3)
    case "⅔":
        return (2, 3)
    case "¼":
        return (1, 4)
    case "¾":
        return (3, 4)
    case "⅕":
        return (1, 5)
    case "⅖":
        return (2, 5)
    case "⅗":
        return (3, 5)
    case "⅘":
        return (4, 5)
    case "⅙":
        return (1, 6)
    case "⅚":
        return (5, 6)
    case "⅐":
        return (1, 7)
    case "⅛":
        return (1, 8)
    case "⅜":
        return (3, 8)
    case "⅝":
        return (5, 8)
    case "⅞":
        return (7, 8)
    default:
        return nil
    }
}
