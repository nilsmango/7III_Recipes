//
//  Parser.swift
//  MDRecipes
//
//  Created by Simon Lang on 22.03.23.
//

import Foundation

struct Parser {
    static let decimalCharacters = CharacterSet.decimalDigits
    
    static let units = ["g", "kg", "ml", "l", "dl", "hl", "cups", "cup", "tsp.", "Tbsp.", "EL", "TL", "packet", "some", "Packet", "Dose", "Kiste", "Teelöffel", "Esslöffel", "pinch", "pinches", "Eine", "Prise", "Prisen", "mg", "L", "Liter", "Ltr.", "ounce", "ounces", "approx.", "approximately", "etwa", "tablespoons", "tablespoon", "teaspoon", "teaspoons", "heaped", "clove", "cloves", "Zehe", "Zehen", "whole", "ganze", "ganz", "zum Anbraten", "wenig", "Messerspitze"]
    
    
    static func makeCleanArray(from: String) -> [String] {
        let stringArray = from.components(separatedBy: " ")
        let cleanArray = stringArray.filter( { $0 != "" })
        return cleanArray
    }
    
    
    /// extract the categories from a recipe
    static func extractCategories(from string: String) -> [String] {
        var categories = [String]()
        
        if let range = string.range(of: "Categories:.*\n", options: .regularExpression) ?? string.range(of: "Kategorien:.*\n", options: .regularExpression) {
            let categoryString = string[range]
            let cleanedCategories = categoryString.replacingOccurrences(of: "Categories: ", with: "").replacingOccurrences(of: "Kategorien: ", with: "").replacingOccurrences(of: "\n", with: "")
            let stringArray = cleanedCategories.components(separatedBy: ", ")
            let cleanArray = stringArray.filter( { $0 != "" })
            for string in cleanArray {
                if categories.contains(string) == false {
                    categories.append(string)
                }
            }
        }
        return categories
    }
    
    /// extract only the ingredient name from ingredient with amount
    static func extractOnlyIngredient(from string: String) -> String {
        let words = string.split(separator: " ")
        var ingredient = String()
        
        for word in words {
            if word.rangeOfCharacter(from: decimalCharacters) == nil && units.description.lowercased().contains(String(word).lowercased()) == false {
                ingredient = ingredient + " " + word
            }
        }
        return ingredient
    }
    
    /// extract ingredients list with amounts from recipe
    static func extractIngredients(from string: String) -> [String] {
        let regex = try? NSRegularExpression(pattern: "- \\[ \\] ([^\\n]+)", options: .anchorsMatchLines)
        var ingredients = [String]()
        
        let matches = regex?.matches(in: string, options: [], range: NSRange(string.startIndex..<string.endIndex, in: string))
        for match in matches ?? [] {
            if let range = Range(match.range, in: string) {
                let almostIngredient = String(string[range])
                let ingredient = almostIngredient.replacingOccurrences(of: "- [ ] ", with: "")
                ingredients.append(ingredient)
            }
        }
        return ingredients
    }
    
    /// cleaning up the ingredient string
    static func cleanUpIngredientString(string: String) -> String {
        
        var newString = string
        
        for index in newString.indices {
            if index < newString.index(before: newString.endIndex) {
                if newString[index].isNumber {
                    if newString[newString.index(after: index)].isLetter {
                        newString.insert(" ", at: newString.index(after: index))
                    }
                } else if newString[index].isLetter {
                    if newString[newString.index(after: index)].isNumber {
                        newString.insert(" ", at: newString.index(after: index))
                    }
                }
            }
        }
        
        return newString
    }
    
    
    
    /// extract the servings from a recipe
    static func extractServings(from string: String) -> Int {
        if let range = string.range(of: "Servings:.*\n", options: .regularExpression) ?? string.range(of: "Portionen:.*\n", options: .regularExpression) {
            let ratingString = string[range]
            let cleanedRating = ratingString.replacingOccurrences(of: "Servings: ", with: "").replacingOccurrences(of: "Portionen: ", with: "").replacingOccurrences(of: "\n", with: "")
            return Int(cleanedRating) ?? 1
        } else {
            return 1
        }
    }
    
    /// extract a rating from a recipe
    static func extractRating(from string: String) -> String {
        if let range = string.range(of: "Rating:.*\n", options: .regularExpression) ?? string.range(of: "Bewertung:.*\n", options: .regularExpression) {
            let ratingString = string[range]
            let cleanedRating = ratingString.replacingOccurrences(of: "Rating: ", with: "").replacingOccurrences(of: "Bewertung: ", with: "").replacingOccurrences(of: "\n", with: "")
            return cleanedRating
        } else {
            return "-"
        }
    }
    
    /// extract total time from a recipe
    static func extractTotalTime(from string: String) -> Int {
        var totalTime = 0
        
        if let range = string.range(of: "Total time:.*\n", options: .regularExpression) ?? string.range(of: "Gesamtzeit:.*\n", options: .regularExpression) {
            let categoryString = string[range]
            let cleanedTime = categoryString.replacingOccurrences(of: "Total time: ", with: "").replacingOccurrences(of: "Gesamtzeit: ", with: "").replacingOccurrences(of: "\n", with: "")
            totalTime = calculateTimeInMinutes(input: cleanedTime)
        }
        return totalTime
    }
    
    /// calculate the time in minutes from a time string
    private static func calculateTimeInMinutes(input: String) -> Int  {
        let cleanedString = input.replacingOccurrences(of: " ", with: "")
        
        var numberArr = [Int]()
        var hours = 0
        var minutes = 0
        
        for element in cleanedString {
            let stringElement = String(element)
            //check if number or character
            if element.isNumber {
                numberArr.append(Int(stringElement)!)
            } else if element.isLetter {
                
                if stringElement.lowercased() == "h" || stringElement.lowercased() == "s" {
                    if numberArr.count > 1 {
                        var count = numberArr.count
                        for number in numberArr {
                            hours += number * Int(pow(10, Double(count - 1)))
                            count = count - 1
                        }
                        numberArr.removeAll()
                        
                        
                    } else {
                        hours = numberArr.first ?? 0
                        numberArr.removeAll()
                    }
                } else if stringElement.lowercased() == "m" {
                    if numberArr.count > 1 {
                        print(numberArr)
                        var count = numberArr.count
                        for number in numberArr {
                            minutes += number * Int(pow(10, Double(count - 1)))
                            count = count - 1
                        }
                    } else {
                        minutes = numberArr.first ?? 0
                    }
                }
            }
        }
        
        return hours * 60 + minutes
    }
    
    
    /// Extract the directions from a recipe
    static func extractDirections(from string: String, withNumbers: Bool) -> [String] {
        var range = 1
        if withNumbers {
            range = 0
        }
        let pattern = "^\\d+\\.\\s(.+)$"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
            let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
            let directions = matches.map { match in
                return (string as NSString).substring(with: match.range(at: range))
            }
            return directions
        } catch {
            return ["Could not find Directions. Try to write them with 1., 2. etc"]
        }
    }
    
    /// Find a timer in a direction and extract minutes, nil if nothing found
    static func extractTimerInMinutes(from string: String) -> Int {
        // Define the regular expression pattern
        let pattern = "(\\d*\\.?\\d+)\\s*([a-zA-Z]+)"
        
        // Create a regular expression object
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            fatalError("Invalid regular expression pattern")
        }
        
        var times = [Double]()
        var units = [String]()
        
        // Match the regular expression against the input string
        let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
        
        // Loop through each match and extract the number and the string
        for match in matches {
            let numberString = (string as NSString).substring(with: match.range(at: 1))
            let unitString = (string as NSString).substring(with: match.range(at: 2))
            
            // Convert the number string to a Double
            guard let number = Double(numberString) else {
                fatalError("Invalid number")
            }
            times.append(number)
            units.append(unitString)
        }
        
        var index = 0
        for time in times {
            if units[index].first!.lowercased() == "h" {
                times[index] = time * 60
            } else if units[index].first!.lowercased() == "m" {
                // all good
            } else if units[index].first!.lowercased() == "s" {
                times[index] = time / 60
            }
            index += 1
        }
        return Int(times.reduce(0, +))
    }
    
    
    
    
    
    
    
    /// Extract the cooking counter from a recipe
    static func extractTimesCooked(from string: String) -> Int {
        
        var counter = 0
        
        if let range = string.range(of: "Times cooked:.*\n", options: .regularExpression) ?? string.range(of: "Zubereitungen:.*\n", options: .regularExpression) {
            let categoryString = string[range]
            let cleanedInt = categoryString.replacingOccurrences(of: "Times cooked: ", with: "").replacingOccurrences(of: "Zubereitungen: ", with: "").replacingOccurrences(of: "\n", with: "")
            counter = Int(cleanedInt) ?? 0
        }
        return counter
    }
    
    /// Increase the cooking counter of a recipe by count
    static func changeTimesCooked(of string: String, to count: Int) -> String {
        var newString = string
        if let range = newString.range(of: "Times Cooked:.*\n", options: .regularExpression) {
            newString.replaceSubrange(range, with: "Times Cooked: \(count)\n")
            return newString
        } else if let range = newString.range(of: "Zubereitungen:.*\n", options: .regularExpression) {
            newString.replaceSubrange(range, with: "Zubereitungen: \(count)\n")
            return newString
        } else if newString.contains("## Zutaten") {
            return addStringBeforeString(for: string, beforeString: "## Zutaten", stringToAdd: "Zubereitungen: \(count)\n\n")
        } else {
            return addStringBeforeString(for: string, beforeString: "## Ingredients", stringToAdd: "Times cooked: \(count)\n\n")
        }
        
    }
    
    /// Add a string before another string
    private static func addStringBeforeString(for string: String, beforeString: String, stringToAdd: String) -> String {
        
        if let range = string.range(of: beforeString) {
            let index = string.distance(from: string.startIndex, to: range.lowerBound)
            let prefix = string.prefix(index)
            let suffix = string.suffix(from: range.lowerBound)
            return prefix + stringToAdd + suffix
        } else {
            return string
        }
    }
}
