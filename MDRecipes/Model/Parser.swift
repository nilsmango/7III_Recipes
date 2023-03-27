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
    private static func cleanUpIngredientString(string: String) -> String {
        
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
            let servingString = string[range]
            let cleanedServings = servingString.replacingOccurrences(of: "Servings: ", with: "").replacingOccurrences(of: "Portionen: ", with: "").replacingOccurrences(of: "\n", with: "")
            return Int(cleanedServings) ?? 1
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
            return ""
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
    static func extractTimerInMinutes(from string: String) -> Double {
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
            if units[index].first!.lowercased() == "h" || units[index].first!.lowercased() == "st" {
                times[index] = time * 60
            } else if units[index].first!.lowercased() == "m" {
                // all good
            } else if units[index].first!.lowercased() == "s" {
                times[index] = time / 60
            }
            index += 1
        }
        return Double(times.reduce(0, +))
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
    
    /// formatting time to show h, min and s if and where we need to in a button
    static func formatTime(_ time: Double) -> String {
        if time >= 60 {
            if time.truncatingRemainder(dividingBy: 60) == 0 {
                return "\(Int(time / 60)) h"
            } else {
                return "\(Int(time / 60)) h \(Int(time.truncatingRemainder(dividingBy: 60))) min"
            }
        } else if time >= 1 {
            return "\(Int(time)) min"
        } else {
            return "\(Int(time * 60)) s"
        }
    }
    
    /// getting a flexible string of the ingredient
    static func stringMaker(of cleanIngredient: String, selectedServings: Int, recipeServings: Int) -> String {
    
        
        let numbersRange = cleanIngredient.rangeOfCharacter(from: .decimalDigits)
        
        if numbersRange != nil || cleanIngredient.components(separatedBy: .whitespaces).first?.lowercased() == "one" ||  cleanIngredient.components(separatedBy: .whitespaces).first?.lowercased() == "two" ||  cleanIngredient.components(separatedBy: .whitespaces).first?.lowercased() == "a"  ||  cleanIngredient.components(separatedBy: .whitespaces).first?.lowercased() == "an" || cleanIngredient.components(separatedBy: .whitespaces).first?.lowercased() == "ein" || cleanIngredient.components(separatedBy: .whitespaces).first?.lowercased() == "eine" || cleanIngredient.components(separatedBy: .whitespaces).first?.lowercased() == "zwei"  {
            
            let input = cleanIngredient.components(separatedBy: .whitespaces).map { String($0) }
            
            var rawAmount = 1.0
            // hier auch checken ob "one" oder "two" ist
            if input.first!.lowercased() == "two" || input.first!.lowercased() == "zwei" {
                rawAmount = 2.0
            } else {
                rawAmount = Double(input.first!) ?? 1
            }
            
            
            let amount = (rawAmount * Double(selectedServings)) / Double(recipeServings)
            
            var amountString: String
            
            if floor(amount) == amount {
                amountString = String(Int(amount))
            } else {
                amountString = String((amount*10).rounded()/10)
            }
            
            let rest = input.dropFirst()
            // getting complicated pluralizing
            if rest.count > 1  {
                // TODO: ideas: check if one ingredient word is capitalized, if yes, then only capitalize that word.
                
                let output = rest.joined(separator: " ")
                let secondPart = " " + output
    
                return amountString + secondPart
                
                // easy to pluralize
            } else {
                let output = rest.joined(separator: " ")
                let secondPart = " " + output
                
                // TODO: if amount is 1. try to singularize ingredient
                if rawAmount == 1.0 && amount != 1.0 {
                    if secondPart.lowercased() == " lauch" {
                        return amountString + " Lauch"
                    } else {
                        return amountString + secondPart.pluralized
                    }
                    
                } else {
                    return amountString + secondPart
                }
            }
            
        } else {
            return cleanIngredient
        
        }
    }
    
    
    
    
    // RECIPE to MARKDOWN and vice versa
    
    
    // find a value for a given key or alternative key (second language) in the markdown file
    private static func findValue(for key: String, or key2: String? = nil, in lines: [String]) -> String? {
        
        if let value = lines.first(where: { $0.hasPrefix("\(key)") }) {
            return value.replacingOccurrences(of: "\(key)", with: "")
        }
        if key2 != nil {
            let value = lines.first(where: { $0.hasPrefix("\(key2!)") })
            return value?.replacingOccurrences(of: "\(key2!)", with: "")
        }
        return nil
    }
    
    // extracting, cleaning and calculating prep, cook, etc. times
    private static func parsingTimes(for english: String, or german: String, in lines: [String]) -> String {
        if let rawValue = findValue(for: english, or: german, in: lines) {
            let minuteValue = Double(calculateTimeInMinutes(input: rawValue))
            let outputString = formatTime(minuteValue)
            
            return outputString
        }
        return ""
        
    }
    
    // find the Ingredients or Zutaten list in the markdown file
    private static func findIngredients(in lines: [String]) -> [Ingredient] {
        var ingredients: [Ingredient] = []
        if let ingredientIndex = lines.firstIndex(where: { $0 == "## Ingredients" || $0 == "## Zutaten" }) {
            let nextTitleIndex = lines[ingredientIndex+1..<lines.count].firstIndex(where: { $0.hasPrefix("## ") }) ?? lines.count
            for i in ingredientIndex+1..<nextTitleIndex {
                let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                let rawString = line.replacingOccurrences(of: "- [ ]", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                let ingredientString = cleanUpIngredientString(string: rawString)
                let ingredient = Ingredient(name: ingredientString)
                
                ingredients.append(ingredient)
                
            }
        }
        return ingredients
    }
    
    // find the Directions or Zubereitung in the markdown file
    private static func findDirections(in lines: [String]) -> [Direction] {
        var directions: [Direction] = []
        if let directionIndex = lines.firstIndex(where: { $0 == "## Directions" || $0 == "## Zubereitung"}) {
            for i in directionIndex+1..<lines.count {
                let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                if line.hasPrefix("\(directions.count+1).") {
                    let text = line
                    let timerInMinutes = extractTimerInMinutes(from: line)
                    let hasTimer = timerInMinutes > 0 ? true : false
                    let direction = Direction(step: directions.count+1, text: text, hasTimer: hasTimer, timerInMinutes: timerInMinutes)
                    directions.append(direction)
                } else {
                    break
                }
            }
        }
        return directions
    }
    
    
    // find the nutrition facts
    private static func findNutrition(in lines: [String]) -> String {
        if let nutritionIndex = lines.firstIndex(where: { $0 == "## Nutrition" || $0 == "## Nährwertangaben"}) {
            let nextTitleIndex = lines[nutritionIndex+1..<lines.count].firstIndex(where: { $0.hasPrefix("## ")}) ?? lines.count - 1
            let nutritionLines = lines[nutritionIndex+1..<nextTitleIndex].map { $0.trimmingCharacters(in: .whitespaces) }
            let nutritionText = nutritionLines.joined(separator: "\n")
            return nutritionText
        }
        return ""
    }
    
    
    // find the notes section in the markdown file
    private static func findNotes(in lines: [String]) -> String {
        if let notesIndex = lines.firstIndex(where: { $0 == "## Notes" || $0 == "## Notizen"}) {
            let nextTitleIndex = lines[notesIndex+1..<lines.count].firstIndex(where: { $0.hasPrefix("## ")}) ?? lines.count - 1
            let noteLines = lines[notesIndex+1..<nextTitleIndex].map { $0.trimmingCharacters(in: .whitespaces) }
            let noteText = noteLines.joined(separator: "\n")
            return noteText
        }
        return ""
    }
    
   
    
    
    // find the images section in the markdown file
    private static func findImages(in lines: [String]) -> String {
        if let imagesIndex = lines.firstIndex(where: { $0 == "## Images" || $0 == "## Bilder"}) {
            let imageLines = lines[imagesIndex+1..<lines.count]
            var imagesString = ""
            for imageLine in imageLines {
                let startIndex = imageLine.index(imageLine.startIndex, offsetBy: 2) // skip "!["
                let endIndex = imageLine.firstIndex(of: "]")!
                let title = String(imageLine[startIndex..<endIndex]).trimmingCharacters(in: .whitespaces)
                let imagePath = imageLine.components(separatedBy: "(")[1].replacingOccurrences(of: ")", with: "")
                imagesString.append("\(title): \(imagePath)\n")
            }
            return imagesString
        }
        return ""
    }
    
    // find out what language the markdown file is in
    private static func findLanguage(in lines: [String]) -> Language {
        if lines.firstIndex(where: { $0 == "## Zutaten" }) != nil {
            return .german
        } else {
            return .english
        }
        
    }
    
    
    
    
    /// Creating a Recipe struct from a Markdown Recipe.
    /// With German and English parsing
    ///
    static func makeRecipeFromMarkdown(markdown: MarkdownFile) -> Recipe {
        
        var lines = markdown.content.components(separatedBy: "\n")
        lines.removeAll(where: { $0 == "\n" || $0 == "" } )
        
        let title = findValue(for: "# ", in: lines) ?? "No Title Found"
        let source = findValue(for: "Source: ", or: "Quelle: ", in: lines) ?? "Unknown"
        let categories = findValue(for: "Categories: ", or: "Kategorien: ", in: lines)?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).capitalized } ?? [""]
        let tags = findValue(for: "Tags: ", in: lines)?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } ?? [""]
        let rating = findValue(for: "Rating: ", or: "Bewertung: ", in: lines) ?? ""
        let prepTime = parsingTimes(for: "Prep time: ", or: "Vorbereitungszeit: ", in: lines)
        let cookTime = parsingTimes(for: "Cook time: ", or: "Kochzeit: ", in: lines)
        let additionalTime = parsingTimes(for: "Additional time: ", or: "Zusätzliche Zeit: ", in: lines)
        let totalTime = parsingTimes(for: "Total time: ", or: "Gesamtzeit: ", in: lines)
        let servings = findValue(for: "Servings:", or: "Portionen: ", in: lines).flatMap { Int($0) } ?? 4
        let timesCooked = findValue(for: "Times cooked:", or: "Zubereitungen:", in: lines).flatMap { Int($0) } ?? 0
        let ingredients = findIngredients(in: lines)
        let directions = findDirections(in: lines)
        let nutrition = findValue(for: "Nutrition", or: "Nährwertangaben", in: lines) ?? ""
        let notes = findNotes(in: lines)
        let images = findImages(in: lines)
        let language = findLanguage(in: lines)
        
        return Recipe(title: title, source: source, categories: categories, tags: tags, rating: rating, prepTime: prepTime, cookTime: cookTime, additionalTime: additionalTime, totalTime: totalTime, servings: servings, timesCooked: timesCooked, ingredients: ingredients, directions: directions, nutrition: nutrition, notes: notes, images: images, language: language)
    }
    
    
    static func makeMarkdownFromRecipe(recipe: Recipe) -> MarkdownFile {
        var lines: [String] = []
        
        // Recipe title
        lines.append("# \(recipe.title)")
        
        // Source
        let sourceKey = recipe.language == .german ? "Quelle" : "Source"
        lines.append("\(sourceKey): \(recipe.source)")
        
        
        // Categories
        let categoriesKey = recipe.language == .german ? "Kategorien" : "Categories"
        let categoriesValue = recipe.categories.joined(separator: ", ")
        lines.append("\(categoriesKey): \(categoriesValue)")
        
        
        // Tags
        let tagsKey = "Tags"
        let tagsValue = recipe.tags.joined(separator: ", ")
        lines.append("\(tagsKey): \(tagsValue)")
        
        
        // Rating
        let ratingKey = recipe.language == .german ? "Bewertung" : "Rating"
        let ratingValue = String(recipe.rating)
        lines.append("\(ratingKey): \(ratingValue)")
        
        // Prep time
        let prepTimeKey = recipe.language == .german ? "Vorbereitungszeit" : "Prep time"
        let prepTimeValue = "\(recipe.prepTime) min"
        lines.append("\(prepTimeKey): \(prepTimeValue)")
        
        // Cook time
        let cookTimeKey = recipe.language == .german ? "Kochzeit" : "Cook time"
        let cookTimeValue = "\(recipe.cookTime) min"
        lines.append("\(cookTimeKey): \(cookTimeValue)")
        
        // Additional time
        let addTimeKey = recipe.language == .german ? "Zusätzliche Zeit" : "Additional time"
        let addTimeValue = "\(recipe.additionalTime) min"
        lines.append("\(addTimeKey): \(addTimeValue)")
        
        // Total time
        let totalTimeKey = recipe.language == .german ? "Gesamtzeit" : "Total time"
        let totalTimeValue = "\(recipe.totalTime) min"
        lines.append("\(totalTimeKey): \(totalTimeValue)")
        
        // Servings
        let servingsKey = recipe.language == .german ? "Portionen" : "Servings"
        let servingsValue = String(recipe.servings)
        lines.append("\(servingsKey): \(servingsValue)")
        
        // Times cooked
        let cookedKey = recipe.language == .german ? "Zubereitungen" : "Times cooked"
        let cookedValue = String(recipe.timesCooked)
        lines.append("\(cookedKey): \(cookedValue)")
        
        
        // Ingredients
        lines.append("")
        let ingredientsTitle = recipe.language == .german ? "## Zutaten" : "## Ingredients"
        lines.append(ingredientsTitle)
        for ingredient in recipe.ingredients {
            let name = " \(ingredient.name)"
            lines.append("- [ ]\(name)")
        }
        
        // Directions
        lines.append("")
        let directionsTitle = recipe.language == .german ? "## Zubereitung" : "## Directions"
        lines.append(directionsTitle)
        for direction in recipe.directions {
            let step = direction.step
            let text = direction.text
            lines.append("\(step). \(text)")
        }
        
        // Nutrition
        lines.append("")
        let nutritionTitle = recipe.language == .german ? "## Nährwertangaben" : "## Nutrition"
        lines.append(nutritionTitle)
        lines.append(recipe.nutrition)
        
        // Notes
        lines.append("")
        let notesTitle = recipe.language == .german ? "## Notizen" : "## Notes"
        lines.append(notesTitle)
        lines.append(recipe.notes)
        
        // Images
        lines.append("")
        let imagesTitle = recipe.language == .german ? "## Bilder" : "## Images"
        lines.append(imagesTitle)
        // From this: ("\(title): \(imagePath)") - back to a markdown image link
        let imageLines = recipe.images.components(separatedBy: "\n")
        for line in imageLines {
            if let colonIndex = recipe.images.firstIndex(of: ":"){
                let title = String(line[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                let imagePath = String(line[line.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                lines.append("![\(title)](\(imagePath))")
                }
        }
        lines.append("")
        
        
        // Return the markdown string
        let markdownContent = lines.joined(separator: "\n")
        return MarkdownFile(name: "# \(recipe.title)", content: markdownContent)
    }
}
