//
//  Parser.swift
//  MDRecipes
//
//  Created by Simon Lang on 22.03.23.
//

import Foundation

struct Parser {
    
    // MARK: Constants
    // Note: we are searching for these strings case insensitive.
    static let titleStrings = ["# "]
    static let sourceStrings = ["Source", "Quelle", "Recipe by", "Rezept von", "By"]
    static let categoriesStrings = ["Categories", "Kategorien"]
    static let tagStrings = ["Tags"]
    static let ratingStrings = ["Rating", "Bewertung"]
    static let prepTimeStrings = ["Prep time", "Vorbereitungszeit", "Arbeitszeit", "Vor- und Zubereitung"]
    static let cookTimeStrings = ["Cook time", "Active Time", "Kochzeit", "Backzeit", "Koch-/Backzeit"]
    static let additionalTimeStrings = ["Additional time", "Zusätzliche Zeit"]
    static let totalTimeStrings = ["Total Time", "Gesamtzeit", "Zubereitungszeit"]
    static let servingsStrings = ["Servings", "Serves", "Yields", "Portionen", "Zutaten für", "Zutaten (für", "persons", "for"]
    
    static let ingredientsStrings = ["## Ingredients", "## Zutaten", "Ingredients", "INGREDIENTS", "Zutaten"]
    static let ingredientsCutoff = ["## ", "Directions", "Zubereitung", "DIRECTIONS", "Steps", "Step 1", "Bring", "Instructions", "Auf die", "Nährwerte pro Portion", "Dieses Rezept", "Local Offers", "The cost per serving"]
    
    static let directionsStrings = ["## Directions", "## Zubereitung", "Step 1", "Directions", "Zubereitung", "Method", "Steps", "DIRECTIONS", "Instructions", "Und so wirds"]
    static let directionsCutoff = ["## ", "Nutrition", "Nährwert", "Tips", "Tipps", "I MADE IT", "Notes", "Anmerkung", "Notizen", "Tip"]
    
    static let nutritionStrings = ["## Nutrition", "## Nährwert", "Nutrition", "NUTRITION", "Nährwert"]
    static let nutritionCutoff = ["## ", "Zubereitung", "Ingredients", "Directions", "Zutaten", "Notes", "Notizen", "Tip", "Tipps", "Anmerkung"]
    
    static let notesStrings = ["## Notes", "## Notizen", "Tips", "Tipps", "Tip", "Notes", "Anmerkung", "Notizen"]
    static let tipsStrings = ["Tip:", "Tipps:", "Notes:"]
    static let notesCutoff = ["## "]
    
    // MARK: Main Parsers
    
    /// Creating an Array of RecipeSegments from a String, used to import Recipe from a String
    static func makeSegmentsFromString(string: String) -> [RecipeSegment]  {
        
        // Output Segments
        var recipeSegments = [RecipeSegment]()
        
        // Input lines
        let lines = string.components(separatedBy: "\n")
        
        // Indexes of the found recipe segments
        var indexesFound = Set<Int>()
        
        // Helper for multiple lines
        func checkAndAppendSegmentsAndIndexes(recipePart: RecipeParts, variablesIndex: Any?) {
            if let index = variablesIndex {
                switch index {
                case let intIndex as Int:
                    let line = lines[intIndex]
                    indexesFound.insert(intIndex)
                    recipeSegments.append(RecipeSegment(part: recipePart, lines: [line]))
                case let intArrayIndex as [Int]:
                    let linesArray = intArrayIndex.map { lines[$0] }
                    let cleanedLinesArray = Array(linesArray.drop(while: { $0.isEmpty } ).reversed().drop(while: { $0.isEmpty }).reversed())
                    indexesFound.formUnion(intArrayIndex)
                    recipeSegments.append(RecipeSegment(part: recipePart, lines: cleanedLinesArray))
                default:
                    break
                }
            }
        }
        
        
        // Title
        let title: String
        let titleVariable = findValue(for: titleStrings, in: lines)
        if titleVariable != (nil, nil) {
            title = lines[titleVariable.index!]
            indexesFound.insert(titleVariable.index!)
            recipeSegments.append(RecipeSegment(part: .title, lines: [title]))
        } else  {
            let alternativeTitle = findTitleAlternative(in: lines)
            checkAndAppendSegmentsAndIndexes(recipePart: .title, variablesIndex: alternativeTitle.index)
        }
        
        // Source
        let sourceVariables = findValue(for: sourceStrings, in: lines, anchored: false)
        checkAndAppendSegmentsAndIndexes(recipePart: .source, variablesIndex: sourceVariables.index)
        
        // Categories
        let categoriesVariables = findValue(for: categoriesStrings, in: lines, anchored: false)
        checkAndAppendSegmentsAndIndexes(recipePart: .categories, variablesIndex: categoriesVariables.index)
        
        // Tags
        let tagsVariables = findValue(for: tagStrings, in: lines, anchored: false)
        checkAndAppendSegmentsAndIndexes(recipePart: .tags, variablesIndex: tagsVariables.index)
        
        // Rating
        let ratingVariables = findValue(for: ratingStrings, in: lines, anchored: false)
        if ratingVariables != (nil, nil) {
            checkAndAppendSegmentsAndIndexes(recipePart: .rating, variablesIndex: ratingVariables.index)
        } else {
            let ratingAlternatives = findRatingAlternative(in: lines)
            checkAndAppendSegmentsAndIndexes(recipePart: .rating, variablesIndex: ratingAlternatives.index)
        }
        
        // Times
        func calculateIndexesForTimes(for keys: [String]) -> [Int?] {
            let timeValues = parsingTimes(for: keys, in: lines)
            var indexes = [timeValues.index]
            let cookingTime = timeValues.value
            if cookingTime == "" {
                // check next line has numbers in it
                if timeValues.index != nil {
                    let nextLine = lines[timeValues.index!+1]
                    if (nextLine.rangeOfCharacter(from: decimalCharacters) != nil) {
                        indexes.append(timeValues.index!+1)
                    }
                }
            }
            return indexes
        }
        // Prep Time
        checkAndAppendSegmentsAndIndexes(recipePart: .prepTime, variablesIndex: calculateIndexesForTimes(for: prepTimeStrings))
        // Cook Time
        checkAndAppendSegmentsAndIndexes(recipePart: .cookTime, variablesIndex: calculateIndexesForTimes(for: cookTimeStrings))
        // Additional Time
        checkAndAppendSegmentsAndIndexes(recipePart: .additionalTime, variablesIndex: calculateIndexesForTimes(for: additionalTimeStrings))
        // Total Time
        checkAndAppendSegmentsAndIndexes(recipePart: .totalTime, variablesIndex: calculateIndexesForTimes(for: totalTimeStrings))
        
        
        // Servings
        let servingsVariables = findValue(for: servingsStrings, in: lines, anchored: false)
        var servingsIndexes = [servingsVariables.index]
        // check if the servings string line has a number in it
        if !containsNumber(in: lines[servingsVariables.index!]) {
            // if no number is found check the next line
            let nextLine = lines[servingsVariables.index!+1]
            if containsNumber(in: nextLine) {
                servingsIndexes.append(servingsVariables.index!+1)
            }
        }
        checkAndAppendSegmentsAndIndexes(recipePart: .servings, variablesIndex: servingsIndexes)
        
        
        // Ingredients
        let ingredientsVariables = findIngredients(searchStrings: ingredientsStrings, cutoff: ingredientsCutoff, in: lines)
        checkAndAppendSegmentsAndIndexes(recipePart: .ingredients, variablesIndex: ingredientsVariables.indexes)
        
        
        // Directions
        let directionsVariables = findDirections(searchStrings: directionsStrings, cutoff: directionsCutoff, in: lines)
        checkAndAppendSegmentsAndIndexes(recipePart: .directions, variablesIndex: directionsVariables.indexes)
        
        // Nutrition
        let nutritionVariables = findSection(in: lines, for: nutritionStrings, cutoffStrings: nutritionCutoff)
        checkAndAppendSegmentsAndIndexes(recipePart: .nutrition, variablesIndex: nutritionVariables.indexes)
        
        // Notes
        let notesValues = findSection(in: lines, for: notesStrings, cutoffStrings: notesCutoff)
        let notesIndexes: [Int?]
        if notesValues == (nil, nil) {
            let noteVariables = findValue(for: tipsStrings, in: lines)
            if noteVariables.index != nil && noteVariables.index! >= lines.count - 5 && noteVariables.index! > nutritionVariables.indexes?.last ?? 0 {
                notesIndexes = Array(noteVariables.index!..<lines.count)
            } else {
                notesIndexes = [noteVariables.index]
            }
        } else {
            notesIndexes = notesValues.indexes!
        }
        checkAndAppendSegmentsAndIndexes(recipePart: .notes, variablesIndex: notesIndexes)
        
        
        // Date of Creation
        var dateVariables = findDate(for: "date:", in: lines)
        if dateVariables == (nil, nil) {
            dateVariables = findFirstDateIndexAndDate(in: lines)
        }
        let dateIndex = dateVariables.index
        checkAndAppendSegmentsAndIndexes(recipePart: .date, variablesIndex: dateIndex)
        
        
        // check what parts are not yet segmented
        let totalSet = Set(0..<lines.count)
        let unSegmentedArray = Array(totalSet.subtracting(indexesFound)).sorted()
        
        // Create an array with the continuous unknown lines
        var unSegmentedParts = [[Int]]()
        
        for lineNumber in unSegmentedArray {
            let lastIndex = unSegmentedParts.count - 1
            if lastIndex == -1 || unSegmentedParts[lastIndex].last! + 1 != lineNumber {
                unSegmentedParts.append([lineNumber])
            } else {
                unSegmentedParts[lastIndex].append(lineNumber)
            }
        }
        
        // Map the continuous lines as a unknown segment, only if they are not just ""
        for part in unSegmentedParts {
            let lines = part.map { lines[$0] }
            if lines.joined().trimmingCharacters(in: .whitespaces) != "" {
                let cleanedLines = Array(lines.drop(while: { $0.isEmpty }).reversed().drop(while: { $0.isEmpty }).reversed())
                recipeSegments.append(RecipeSegment(part: .unknown, lines: cleanedLines))
            }
        }
        
        
        // Sort the recipeSegments to represent the original lines
        recipeSegments.sort { lhs, rhs in
            guard let index1 = lines.firstIndex(where: { $0 == lhs.lines.first }),
                  let index2 = lines.firstIndex(where: { $0 == rhs.lines.first }) else {
                return false
            }
            return index1 < index2
        }
        
        return recipeSegments
    }
    
    /// Creating a recipe.data from edited recipe segments in the Import Recipe from String
    static func makeDataFromSegments(segments: [RecipeSegment]) -> Recipe.Data {
        
        // Helper that checks if the normal parsing for the Segment Lines does not give us the desired result and simply takes the Segment Lines as the value in that case
        func makingSureWeGotValue(value: String?, lines: [String], separator: String) -> String {
            if value == "" || value == nil {
                return lines.joined(separator: separator).trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                return value!
            }
        }
        
        
        // Title
        let titleLines = segments.first(where: { $0.part == .title })?.lines ?? ["Unknown"]
        let title: String
        let titleVariable = findValue(for: titleStrings, in: titleLines)
        if titleVariable != (nil, nil) {
            title = titleVariable.value!
        } else  {
            let alternativeTitle = findTitleAlternative(in: titleLines)
            title = alternativeTitle.value
        }
        
        // MARK: until here I have checked the code
        
        // Source
        let sourceLines = segments.first(where: { $0.part == .source })?.lines ?? ["Source: Unknown"]
        let sourceVariables = findValue(for: ["Source:", "Quelle:", "Recipe by", "Rezept von", "BY", "By:"], in: sourceLines)
        let source = makingSureWeGotValue(value: sourceVariables.value, lines: sourceLines, separator: " ")
        
        // Categories
        let categorieLines = segments.first(where: { $0.part == .categories })?.lines ?? []
        let categoriesVariables = findValue(for: ["Categories:", "Kategorien:"], in: categorieLines)
        let rawCategories = makingSureWeGotValue(value: categoriesVariables.value, lines: categorieLines, separator: " ")
        let categories = rawCategories.components(separatedBy: " ")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).capitalized }
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        
        // Tags
        let tagLines = segments.first(where: { $0.part == .tags })?.lines ?? []
        let tagsVariables = findValue(for: ["Tags:"], in: tagLines)
        var rawLine = tagsVariables.value
        if tagsVariables.value == "" || tagsVariables.value == nil {
            rawLine = tagLines.joined(separator: ", ").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let firstIteration = rawLine?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } ?? []
        var tags = [String]()
        for part in firstIteration {
            let partArray = part.components(separatedBy: " ")
            tags += partArray
        }
        // maybe not necessary
        tags = tags.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        // Rating
        let ratingLines = segments.first(where: { $0.part == .rating })?.lines ?? []
        let rating: String
        let ratingVariables = findValue(for: ["Rating:", "Bewertung:"], in: ratingLines)
        if ratingVariables != (nil, nil) {
            rating = ratingVariables.value!
        } else {
            let ratingAlternatives = findRatingAlternative(in: ratingLines)
            rating = ratingAlternatives.value
        }
        
        // Times
        // As we have already matched the lines with the times we only need to find a time
        
        func calculateTimes(for lines: [String]) -> String {
            
            for line in lines {
                if line.rangeOfCharacter(from: decimalCharacters) != nil {
                    let minuteValue = Double(calculateTimeInMinutes(input: line))
                    let cookTime = formatTime(minuteValue)
                    if cookTime != "0 s" && cookTime != "" {
                        return cookTime
                    }
                }
            }
            return ""
        }
        let prepLines = segments.first(where: { $0.part == .prepTime })?.lines ?? []
        let prepTime = calculateTimes(for: prepLines)
        
        let cookLines = segments.first(where: { $0.part == .cookTime })?.lines ?? []
        let cookTime = calculateTimes(for: cookLines)
        
        let addLines = segments.first(where: { $0.part == .additionalTime })?.lines ?? []
        let additionalTime = calculateTimes(for: addLines)
        
        let totalLines = segments.first(where: { $0.part == .totalTime })?.lines ?? []
        let totalTime = calculateTimes(for: totalLines)
        
        // TODO: this does not work yet
        // Servings
        let servingsLines = segments.first(where: { $0.part == .servings })?.lines ?? ["4"]
        // case insensitive but anchored
        let servingsVariables = findValue(for: ["Servings:", "Servings", "Serves:", "Serves", "YIELDS:", "Yields", "Portionen:", "Zutaten für", "Zutaten (für"], in: servingsLines)
        // find the first number in the lines if findValue doesn't work
        var servings = Int()
        if servingsVariables.value == "" {
            for line in servingsLines {
                if let number = line.first(where: { $0.isNumber }) {
                    if let servingsInt = Int(String(number)) {
                        servings = servingsInt
                        break
                    }
                }
            }
        } else {
            servings = servingsVariables.value.flatMap { Int($0) } ?? 4
        }
        
        
        // Ingredients
        let ingredientLines = segments.first(where:  { $0.part == .ingredients })?.lines ?? []
        let ingredientsVariables = findIngredients(searchStrings: ["## Ingredients", "## Zutaten", "Ingredients", "INGREDIENTS", "Zutaten", "Zutaten für", ""], cutoff: ["## ", "Directions", "Zubereitung", "DIRECTIONS", "Step 1", "Bring", "Auf die", "Nährwerte pro Portion", "Dieses Rezept", "Local Offers", "The cost per serving", "Instructions"], in: ingredientLines)
        let ingredients = ingredientsVariables.ingredients
        
        // Directions
        let directionLines = segments.first(where:  { $0.part == .directions })?.lines ?? []
        let directionsVariables = findDirections(searchStrings: ["## Directions", "## Zubereitung", "Step 1", "Directions", "Zubereitung", "Method", "Steps", "DIRECTIONS", "Gesamtzeit", "Instructions", "Und so wirds gemacht:", ""], cutoff: ["## ", "Nährwert pro Portion", "Tips", "Tip:", "Tipps:", "I MADE IT", "Notes"], in: directionLines)
        let directions = directionsVariables.directions
        
        // Nutrition
        let nutriLines = segments.first(where:  { $0.part == .nutrition })?.lines ?? []
        let nutritionVariables = findSection(in: nutriLines, for: ["## Nutrition", "## Nährwertangaben", "Nährwerte pro Portion", "Nährwerte", "Nährwert pro Portion", "NUTRITION PER SERVING", "Nutrition Facts"], cutoffStrings: ["## ", "Zubereitung", "Ingredients"])
        let nutrition: String
        
        if nutritionVariables.value == nil {
            nutrition = nutriLines.joined(separator: "\n")
        } else {
            nutrition = nutritionVariables.value ?? ""
        }
        
        // Notes
        let noteLines = segments.first(where:  { $0.part == .notes })?.lines ?? []
        
        let notesValues = findSection(in: noteLines, for: ["## Notes", "## Notizen", "Tips", "Notes"], cutoffStrings: ["## "])
        let notes: String
        if notesValues == (nil, nil) {
            notes = noteLines.joined(separator: "\n")
                .replacingOccurrences(of: "Tip:", with: "")
                .replacingOccurrences(of: "Tipps:", with: "")
                .replacingOccurrences(of: "Notes:", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            notes = notesValues.value ?? ""
        }
        
        // Date
        let dateLines = segments.first(where:  { $0.part == .date })?.lines ?? []
        
        var dateVariables = findFirstDateIndexAndDate(in: dateLines)
        if dateVariables == (nil, nil) {
            dateVariables = (Date.now, nil)
        }
        
        let date = dateVariables.date ?? Date.now
        
        
        // Language
        let language: RecipeLanguage
        if ingredientLines.contains("Zutaten") {
            language = .german
        } else {
            language = .english
        }
        
        return Recipe.Data(title: title, source: source, categories: categories, tags: tags, rating: rating, prepTime: prepTime, cookTime: cookTime, additionalTime: additionalTime, totalTime: totalTime, servings: servings, timesCooked: 0, ingredients: ingredients, directions: directions, nutrition: nutrition, notes: notes, dataImages: [], date: date, updated: Date.now, language: language)
    }
    
    /// Creating a Recipe struct from a Markdown Recipe.
    /// With German and English parsing
    static func makeRecipeFromString(string: String) -> (recipe: Recipe, indexes: Set<Int>)  {
        
        // Helper to add the parsed indexes
        func checkAndAppendIndex(input: Int?) {
            if let index = input {
                indexesFound.insert(index)
            }
        }
        
        // Input lines
        let lines = string.components(separatedBy: "\n")
        
        // Output indexes of the found recipe components
        var indexesFound = Set<Int>()
        
        // Title
        let title: String
        let titleVariable = findValue(for: titleStrings, in: lines)
        if titleVariable != (nil, nil) {
            title = titleVariable.value!
            indexesFound.insert(titleVariable.index!)
        } else  {
            let alternativeTitle = findTitleAlternative(in: lines)
            title = alternativeTitle.value
            checkAndAppendIndex(input: alternativeTitle.index)
        }
        
        // Source
        let sourceVariables = findValue(for: sourceStrings, in: lines, anchored: false)
        let source = sourceVariables.value ?? "Unknown"
        checkAndAppendIndex(input: sourceVariables.index)
        
        // Categories
        let categoriesVariables = findValue(for: categoriesStrings, in: lines, anchored: false)
        var categories = categoriesVariables.value?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).capitalized }.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } ?? ["No Category"]
        if categories == [] || categories == [""] { categories = ["No Category"] }
        checkAndAppendIndex(input: categoriesVariables.index)
        
        // Tags
        let tagsVariables = findValue(for: tagStrings, in: lines, anchored: false)
        let tags = tagsVariables.value?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } ?? []
        checkAndAppendIndex(input: tagsVariables.index)
        
        // MARK: checked until here
        
        // Rating
        let rating: String
        let ratingVariables = findValue(for: ratingStrings, in: lines)
        if ratingVariables != (nil, nil) {
            rating = ratingVariables.value!
            checkAndAppendIndex(input: ratingVariables.index)
        } else {
            let ratingAlternatives = findRatingAlternative(in: lines)
            rating = ratingAlternatives.value
            checkAndAppendIndex(input: ratingAlternatives.index)
        }
        
        // Times
        func calculateTimes(for keys: [String]) -> String {
            let timeValues = parsingTimes(for: keys, in: lines)
            var cookingTime = timeValues.value
            checkAndAppendIndex(input: timeValues.index)
            if cookingTime == "" {
                // check next line has numbers in it
                if timeValues.index != nil {
                    let nextLine = lines[timeValues.index!+1]
                    if (nextLine.rangeOfCharacter(from: decimalCharacters) != nil) {
                        let minuteValue = Double(calculateTimeInMinutes(input: nextLine))
                        cookingTime = formatTime(minuteValue)
                        checkAndAppendIndex(input: timeValues.index!+1)
                    }
                }
                
            }
            if cookingTime == "0 s" {
                return ""
            } else {
                return cookingTime
            }
            
        }
        
        let prepTime = calculateTimes(for: prepTimeStrings)
        let cookTime = calculateTimes(for: cookTimeStrings)
        let additionalTime = calculateTimes(for: additionalTimeStrings)
        let totalTime = calculateTimes(for: totalTimeStrings)
        
        // Servings
        let servingsVariables = findValue(for: servingsStrings, in: lines)
        checkAndAppendIndex(input: servingsVariables.index)
        let servings: Int
        if servingsVariables.value == "" {
            // check next line has a number in it
            let nextLine = lines[servingsVariables.index!+1]
            if let number = nextLine.first(where: { $0.isNumber }) {
                servings = Int(String(number)) ?? 4
                checkAndAppendIndex(input: servingsVariables.index!+1)
            } else {
                servings = 4
            }
        } else {
            servings = servingsVariables.value.flatMap { Int($0) } ?? 4
        }
        
        
        // Times cooked
        let timesCookedVariables = findValue(for: ["Times cooked:", "Zubereitungen:"], in: lines)
        let timesCooked = timesCookedVariables.value.flatMap { Int($0) } ?? 0
        checkAndAppendIndex(input: timesCookedVariables.index)
        
        // Ingredients
        let ingredientsVariables = findIngredients(searchStrings: ingredientsStrings, cutoff: ingredientsCutoff, in: lines)
        let ingredients = ingredientsVariables.ingredients
        let indexes = ingredientsVariables.indexes
        indexes.forEach { checkAndAppendIndex(input: $0) }
        
        // Directions
        let directionsVariables = findDirections(searchStrings: directionsStrings, cutoff: directionsCutoff, in: lines)
        let directions = directionsVariables.directions
        let dirIndexes = directionsVariables.indexes
        dirIndexes.forEach { checkAndAppendIndex(input: $0) }
        
        // Nutrition
        let nutritionVariables = findSection(in: lines, for: nutritionStrings, cutoffStrings: nutritionCutoff)
        let nutrition = nutritionVariables.value ?? ""
        let nutritionIndexes = nutritionVariables.indexes
        nutritionIndexes?.forEach { checkAndAppendIndex(input: $0)}
        
        // Notes
        let notesValues = findSection(in: lines, for: notesStrings, cutoffStrings: notesCutoff)
        let notes: String
        if notesValues == (nil, nil) {
            let noteVariables = findValue(for: tipsStrings, in: lines)
            if noteVariables.index != nil && noteVariables.index! >= lines.count - 5 && noteVariables.index! > nutritionIndexes?.last ?? 0 {
                let additionalNotes = lines[noteVariables.index!+1..<lines.count].joined(separator: "\n")
                if noteVariables.value == "" {
                    notes = additionalNotes
                } else {
                    notes = noteVariables.value! + "\n" + additionalNotes
                }
                
                Array(noteVariables.index!..<lines.count).forEach { checkAndAppendIndex(input: $0) }
            } else {
                notes = noteVariables.value ?? ""
                checkAndAppendIndex(input: noteVariables.index)
            }
        } else {
            notes = notesValues.value ?? ""
            let notesIndexes = notesValues.indexes
            notesIndexes?.forEach { checkAndAppendIndex(input: $0) }
        }
        
        
        // Images
        let imageValues = findImages(in: lines)
        let images = imageValues.images
        let imageIndexes = imageValues.indexes
        imageIndexes?.forEach { checkAndAppendIndex(input: $0) }
        
        
        // Date of Creation
        var dateVariables = findDate(for: "date:", in: lines)
        if dateVariables == (nil, nil) {
            dateVariables = findFirstDateIndexAndDate(in: lines)
            if dateVariables == (nil, nil) {
                dateVariables = (Date.now, nil)
            }
        }
        let date = dateVariables.date ?? Date.now
        let dateIndex = dateVariables.index
        checkAndAppendIndex(input: dateIndex)
        
        // Date of Update
        let updatedVariables = findDate(for: "updated:", in: lines)
        let updated = updatedVariables.date ?? Date.now
        let updatedIndex = updatedVariables.index
        checkAndAppendIndex(input: updatedIndex)
        
        // Language
        let language = findLanguage(in: lines)
        
        return (Recipe(title: title, source: source, categories: categories, tags: tags, rating: rating, prepTime: prepTime, cookTime: cookTime, additionalTime: additionalTime, totalTime: totalTime, servings: servings, timesCooked: timesCooked, ingredients: ingredients, directions: directions, nutrition: nutrition, notes: notes, images: images, date: date, updated: updated, language: language), indexesFound)
    }
    
    /// Creating a Markdown Recipe froma a Recipe struct.
    /// With German and English parsing
    static func makeMarkdownFromRecipe(recipe: Recipe) -> MarkdownFile {
        var lines: [String] = []
        // yaml header
        lines.append("---")
        lines.append("date: \(formatDate(recipe.date))")
        lines.append("updated: \(formatDate(recipe.updated))")
        lines.append("---")
        
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
        let prepTimeValue = "\(recipe.prepTime)"
        lines.append("\(prepTimeKey): \(prepTimeValue)")
        
        // Cook time
        let cookTimeKey = recipe.language == .german ? "Kochzeit" : "Cook time"
        let cookTimeValue = "\(recipe.cookTime)"
        lines.append("\(cookTimeKey): \(cookTimeValue)")
        
        // Additional time
        let addTimeKey = recipe.language == .german ? "Zusätzliche Zeit" : "Additional time"
        let addTimeValue = "\(recipe.additionalTime)"
        lines.append("\(addTimeKey): \(addTimeValue)")
        
        // Total time
        let totalTimeKey = recipe.language == .german ? "Gesamtzeit" : "Total time"
        let totalTimeValue = "\(recipe.totalTime)"
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
            let name = " \(ingredient.text)"
            lines.append("- [ ]\(name)")
        }
        
        // Directions
        lines.append("")
        let directionsTitle = recipe.language == .german ? "## Zubereitung" : "## Directions"
        lines.append(directionsTitle)
        for direction in recipe.directions {
            let text = direction.text
            lines.append("\(text)")
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
        for image in recipe.images {
            let imageLine = "![[\(image.imagePath)|\(image.caption)]]"
            lines.append(imageLine)
        }
       
        
        // Return the markdown string
        let markdownContent = lines.joined(separator: "\n")
        let filename = sanitizeFileName(recipe.title)
        return MarkdownFile(name: filename, content: markdownContent)
    }
    
    
    
    // MARK: Parser functions
    
    
    
    /// using the update date of a recipe to determine when it was 60 days in the trash and will get deleted.
    static func daysUntilDeletion(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let futureDate = calendar.date(byAdding: .day, value: 60, to: date)!
        let targetDate = calendar.startOfDay(for: futureDate)
        let components = calendar.dateComponents([.day], from: today, to: targetDate)
        return String(components.day ?? 0)
    }
    
    
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
    static func calculateTimeInMinutes(input: String) -> Int  {
        let cleanedString = input.replacingOccurrences(of: " ", with: "")
        
        var numberArr = [Int]()
        var hours = 0
        var minutes = 0
        var seconds: Double = 0
        
        for (index, element) in cleanedString.enumerated() {
            let stringElement = String(element)
            //check if number or character
            if element.isNumber {
                numberArr.append(Int(stringElement)!)
            } else if element.isLetter {
                // looking for s as well because of the german Stunden.
                if stringElement.lowercased() == "h" || stringElement.lowercased() == "s" && cleanedString.last != element && cleanedString[cleanedString.index(cleanedString.startIndex, offsetBy: index+1)] != "e" {
                    if numberArr.count > 1 {
                        var count = numberArr.count
                        for number in numberArr {
                            hours += number * Int(pow(10, Double(count - 1)))
                            count = count - 1
                        }
                        numberArr.removeAll()
                        
                        
                    } else if numberArr.count == 1 {
                        hours = numberArr.first ?? 0
                        numberArr.removeAll()
                    }
                } else if stringElement.lowercased() == "m" {
                    if numberArr.count > 1 {
                        var count = numberArr.count
                        for number in numberArr {
                            minutes += number * Int(pow(10, Double(count - 1)))
                            count = count - 1
                        }
                        numberArr.removeAll()
                    } else {
                        minutes = numberArr.first ?? 0
                        numberArr.removeAll()
                    }
                } else if stringElement.lowercased() == "s" {
                    if numberArr.count > 1 {
                        var count = numberArr.count
                        for number in numberArr {
                            seconds += Double(number) * pow(10, Double(count - 1))
                            count = count - 1
                        }
                        numberArr.removeAll()
                    } else {
                        seconds = Double(numberArr.first ?? 0)
                        numberArr.removeAll()
                    }
                } else {
                    numberArr.removeAll()
                }
            }
        }
        
        return hours * 60 + minutes + Int((seconds / 60).rounded())
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
            
            if let firstCharacter = cleanIngredient.first, firstCharacter.isLetter {
                return cleanIngredient
            }
            
            
            let input = cleanIngredient.components(separatedBy: .whitespaces).map { String($0) }
            
            var rawAmount = 1.0
            // check if a number word
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
    
    
    /// re-parsing the instructions to render the timers again.
    static func reParsingDirections(directions: [Direction]) -> [Direction] {
        var lines = [String]()
        for direction in directions {
            let text = direction.text
            lines.append("\(text)")
        }
        var newDirections: [Direction] = []
        for line in lines {
            let timerInMinutes = extractTimerInMinutes(from: line)
            let hasTimer = timerInMinutes > 0 ? true : false
            let cleanString = line.trimmingCharacters(in: .newlines)
            let direction = Direction(step: newDirections.count+1, text: cleanString, hasTimer: hasTimer, timerInMinutes: timerInMinutes)
            newDirections.append(direction)
        }
        
        return newDirections
    }
    
    
    
    // MARK: RECIPE to MARKDOWN and vice versa
    
    
    /// Find a value for given keys in an array of strings and remove the key. Case insensitive and with optional non anchoring to start. Returns the String without the key if there is any and the index of the lines.
    private static func findValue(for keys: [String], in lines: [String], anchored: Bool = true) -> (value: String?, index: Int?) {
        for key in keys {
            // search case insensitive and anchored if true
            if anchored {
                if let index = lines.firstIndex(where: { $0.range(of: key, options: [.caseInsensitive, .anchored]) != nil }) {
                    // drop the key until after the first space or ":"
                    let line = lines[index]
                    let lineWithoutKey = String(line.dropFirst(key.count))
                    
                    // find out if there is a :
                    if lineWithoutKey.first == ":" {
                        let value = String(line.dropFirst(key.count + 1).trimmingCharacters(in: .whitespaces))
                        return (value, index)
                    } else {
                        let value = String(line.dropFirst(key.count).trimmingCharacters(in: .whitespaces))
                        return (value, index)
                    }
                }
                
            } else {
                // searching without anchoring to the front
                if let index = lines.firstIndex(where: { $0.range(of: key, options: [.caseInsensitive]) != nil }) {
                    let line = lines[index]
                    let rangeOfKey = line.range(of: key, options: .caseInsensitive)!
                    
                    // drop the key + : or space
                    if let upperRangeOfWholeKey = line[rangeOfKey.upperBound...].range(of: ":") {
                        
                        if line.index(upperRangeOfWholeKey.upperBound, offsetBy: 1, limitedBy: line.endIndex) != nil {
                            let value = String(line[line.index(upperRangeOfWholeKey.upperBound, offsetBy: 1)...]).trimmingCharacters(in: .whitespaces)
                            return (value, index)
                        } else {
                                let value = String(line[line.index(upperRangeOfWholeKey.upperBound, offsetBy: 0)...]).trimmingCharacters(in: .whitespaces)
                                return (value, index)
                            
                        }
                        
                    } else {
                        // just drop the key
                        if line.index(rangeOfKey.upperBound, offsetBy: 1, limitedBy: line.endIndex) != nil {
                            let value = String(line[line.index(rangeOfKey.upperBound, offsetBy: 1)...]).trimmingCharacters(in: .whitespaces)
                            return (value, index)
                        } else {
                            let value = String(line[line.index(rangeOfKey.upperBound, offsetBy: 0)...]).trimmingCharacters(in: .whitespaces)
                            return (value, index)
                        }
                    }
                }
            }
            
        }
        return (nil, nil)
    }
    
    // extracting, cleaning and calculating prep, cook, etc. times
    private static func parsingTimes(for keys: [String], in lines: [String]) -> (value: String, index: Int?) {
        let rawValue = findValue(for: keys, in: lines, anchored: false)
        if rawValue != (nil, nil) {
            let string = rawValue.value
            let index = rawValue.index
            let minuteValue = Double(calculateTimeInMinutes(input: string!))
            let outputString = formatTime(minuteValue)
            
            return (outputString, index)
        }
        return ("", nil)
        
    }
    
    /// find the Ingredients or Zutaten list in the markdown file
    private static func findIngredients(searchStrings: [String], cutoff: [String], in lines: [String]) -> (ingredients: [Ingredient], indexes: [Int]) {
        var ingredients: [Ingredient] = []
        var indexes = [Int]()
        // looking for the first line that has the prefix that contains one of the search strings
        if let ingredientIndex = lines.firstIndex(where: { line in
            searchStrings.contains { prefix in
            line.hasPrefix(prefix)
        } }) {
            indexes.append(ingredientIndex)
            
            // looking for the first line after the ingredients title that has the prefix of the cutoff search strings
            let nextTitleIndex = lines[ingredientIndex+1..<lines.count].firstIndex { line in
                cutoff.contains { prefix in
                    line.hasPrefix(prefix)
                }
            } ?? lines.count
            
            // now making the ingredients into a checklist
            for i in ingredientIndex+1..<nextTitleIndex {
                let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                let rawString = line.replacingOccurrences(of: "- [ ]", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                let ingredientString = cleanUpIngredientString(string: rawString)
                let cleanIngredient = convertFractionToDouble(ingredientString)
                indexes.append(i)
                
                if rawString != "" && rawString != "Portionen" && rawString != "Anzahl Personen" {
                    ingredients.append(Ingredient(text: cleanIngredient))
                    
                }
            }
        }
        return (ingredients, indexes)
    }
    
    // find the Directions or Zubereitung in the markdown file
    static func findDirections(searchStrings: [String], cutoff: [String], in lines: [String]) -> (directions: [Direction], indexes: [Int]) {
        var directions: [Direction] = []
        var indexes = [Int]()
        let directionArray: [String]
        
        // special parsing for segments (meaning searchStrings will contain ""
        // find the line that has the prefix of the search string
        if let directionIndex = lines.firstIndex(where:  { line in
            searchStrings.contains { prefix in
            line.hasPrefix(prefix)
        } }) {
            
            // looking for the first line after the ingredients title that has the prefix of the cutoff search strings
            let directionEndIndex = lines[directionIndex+1..<lines.count].firstIndex { line in
                cutoff.contains { prefix in
                    line.hasPrefix(prefix)
                }
            } ?? lines.count
            
            directionArray = Array(lines[directionIndex+1..<directionEndIndex])
            // add the indexes
            let indexRange = (directionIndex..<directionEndIndex)
            indexes += indexRange
            
        } else if searchStrings.contains("") {
            directionArray = lines
            indexes = Array(0..<lines.count)
        } else {
            directionArray = []
        }
        
        directions = directionsFromStrings(strings: directionArray)
        
        
        return (directions, indexes)
    }
    
    /// make Directions from an Array of Strings
    static func directionsFromStrings(strings: [String]) -> [Direction] {
        var directions: [Direction] = []
        var currentString = ""
        
        // determine which kind of directions pattern we have.
        let startsWithNumber = "^\\d+.*"
        let startsWithStepNumber = "^Step\\s+\\d+.*"
        
        // TODO: make this work if no strings are in the first
        let testString = strings.first!
        
        // "Starts with a number"
        if testString.range(of: startsWithNumber, options: .regularExpression) != nil {
            for line in strings {
                // clean it up
                let cleanLine = addPeriodToNumberedString(line)
                // use regular expression to match the first string that begins with a number
                if cleanLine.range(of: #"^\d+\."#, options: .regularExpression) != nil {
                    
                    // append the current string to the directions array if it's not empty
                    if currentString.isEmpty == false {
                        let timerInMinutes = extractTimerInMinutes(from: currentString)
                        let hasTimer = timerInMinutes > 0.2 ? true : false
                        currentString = currentString.trimmingCharacters(in: .newlines)
                        let direction = Direction(step: directions.count+1, text: currentString, hasTimer: hasTimer, timerInMinutes: timerInMinutes)
                        directions.append(direction)
                    }
                    // start a new string with the matched string
                    currentString = cleanLine.trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    // append the current string to the current string with a newline character
                    currentString += "\n" + cleanLine.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            // append the last current string to the directions array
            let timerInMinutes = extractTimerInMinutes(from: currentString)
            let hasTimer = timerInMinutes > 0 ? true : false
            currentString = currentString.trimmingCharacters(in: .whitespacesAndNewlines)
            let direction = Direction(step: directions.count+1, text: currentString, hasTimer: hasTimer, timerInMinutes: timerInMinutes)
            directions.append(direction)
            
            
            // "Starts with 'Step' and a number"
        } else if testString.range(of: startsWithStepNumber, options: .regularExpression) != nil {
            var currentString = ""
            for line in strings {
                if line.hasPrefix("Step") {
                    // append the current string to the directions array if it's not empty
                    if currentString != "" {
                        let timerInMinutes = extractTimerInMinutes(from: currentString)
                        let hasTimer = timerInMinutes > 0 ? true : false
                        currentString = currentString.trimmingCharacters(in: .newlines)
                        let direction = Direction(step: directions.count + 1, text: currentString, hasTimer: hasTimer, timerInMinutes: timerInMinutes)
                        directions.append(direction)
                    }
                    // start a new current string
                    currentString = "\(directions.count + 1). "
                    
                }
                currentString += "\n" + line.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            // append the last current string to the directions array
            let timerInMinutes = extractTimerInMinutes(from: currentString)
            let hasTimer = timerInMinutes > 0 ? true : false
            currentString = currentString.trimmingCharacters(in: .newlines)
            let direction = Direction(step: directions.count + 1, text: currentString, hasTimer: hasTimer, timerInMinutes: timerInMinutes)
            directions.append(direction)
            
            // No numbers and no steps
        } else {
            let linesCount = strings.count
            
            if linesCount <= 2 {
                for line in strings {
                    let splitLines = line.split(separator: ". ")
                    for line in splitLines {
                        let currentString = String(line + ".")
                        let timerInMinutes = extractTimerInMinutes(from: currentString)
                        let hasTimer = timerInMinutes > 0 ? true : false
                        let directionString = "\(directions.count+1). " + currentString
                        let direction = Direction(step: directions.count+1, text: directionString, hasTimer: hasTimer, timerInMinutes: timerInMinutes)
                        directions.append(direction)
                    }
                }
            } else {
                for line in strings {
                    let timerInMinutes = extractTimerInMinutes(from: line)
                    let hasTimer = timerInMinutes > 0 ? true : false
                    let directionString = "\(directions.count+1). " + line
                    let direction = Direction(step: directions.count+1, text: directionString, hasTimer: hasTimer, timerInMinutes: timerInMinutes)
                    directions.append(direction)
                }
            }
            // check how many lines - if less than 2? also count each line.
        }
        return directions
    }
    
    /// Turning a String of Directions into an array of Directions
    static func makingDirectionsFromString(directionsString: String) -> [Direction] {
        let strings = directionsString.components(separatedBy: .newlines)
        let updatedDirections = Parser.directionsFromStrings(strings: strings)
        
        return updatedDirections
    }
    
    
    private static func addPeriodToNumberedString(_ inputString: String) -> String {
        let startsWithNumberPattern = #"^\d{1,2}"#
        let startsWithNumberAndDotPattern = #"^(\d+)\."#
        
        // starts with number and dot
        if inputString.range(of: startsWithNumberAndDotPattern, options: .regularExpression) != nil {
            let newString = inputString.split(separator: ".", maxSplits: 2)
            let secondPart = newString.last!.trimmingCharacters(in: .whitespaces)
            let outputString = String(newString.first! + ". " + secondPart)
            return outputString
            
            // starts with only number
        } else if let range = inputString.range(of: startsWithNumberPattern, options: .regularExpression) {
            let matchedSubstring = String(inputString[range])
            let startIndex = matchedSubstring.count
            let rest = inputString.dropFirst(startIndex)
            
            let outputString = matchedSubstring + ". " + rest
            return outputString
        } else {
            return inputString
        }
    }
    
    /// function to create a direction from a string
    static func createDirection(from string: String, directionsCount: Int) -> Direction {
        let timerInMinutes = extractTimerInMinutes(from: string)
        let hasTimer = timerInMinutes > 0 ? true : false
        let step = directionsCount + 1
        let newString = String(step) + ". " + string.trimmingCharacters(in: .newlines)
        let direction = Direction(step: step, text: newString, hasTimer: hasTimer, timerInMinutes: timerInMinutes)
        
        return direction
    }
    
    /// create a string from directions
    static func createString(from directions: [Direction]) -> String {
        var output = ""
        for direction in directions {
            output.append(direction.text)
        }
        return output
    }
    
    
    // find a certain section in the markdown file
    private static func findSection(in lines: [String], for searchStrings: [String], cutoffStrings: [String]) -> (value: String?, indexes: [Int]?) {
        if let sectionIndex = lines.firstIndex(where: { searchStrings.contains($0) }) {
            let nextTitleIndex = lines[sectionIndex+1..<lines.count].firstIndex { line in
                cutoffStrings.contains { prefix in
                    line.hasPrefix(prefix)
                }
            } ?? lines.count
            
            let sectionLines = lines[sectionIndex+1..<nextTitleIndex].map { $0.trimmingCharacters(in: .whitespaces) }
            let sectionText = sectionLines.joined(separator: "\n").trimmingCharacters(in: .newlines)
            let indexes = Array(sectionIndex..<nextTitleIndex)
            return (sectionText, indexes)
        }
        return (nil, nil)
    }
    
    // find the images section in the markdown file
    private static func findImages(in lines: [String]) -> (images: [RecipeImage], indexes: [Int]?) {
        if let imagesIndex = lines.firstIndex(where: { $0 == "## Images" || $0 == "## Bilder"}) {
            let imageLines = lines[imagesIndex+1..<lines.count]
            let imagesString = imageLines.joined(separator: "\n")
            let images = extractImages(from: imagesString)
            
            return (images, Array(imagesIndex+1..<lines.count))
        }
        return ([], nil)
    }
    
    
    private static func extractImages(from text: String) -> [RecipeImage] {
        var images: [RecipeImage] = []
        
        let regex1 = try! NSRegularExpression(pattern: "!\\[\\[(.*?)\\]\\]")
        let regex2 = try! NSRegularExpression(pattern: "!\\[(.*?)\\]\\((.*?)\\)")
        
        regex1.enumerateMatches(in: text, range: NSMakeRange(0, text.utf16.count)) { match, _, _ in
            guard let match = match else { return }
            let range = Range(match.range(at: 1), in: text)!
            let matchString = String(text[range])
            let components = matchString.components(separatedBy: "|")
            if components.count == 2 {
                let path = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let caption = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                images.append(RecipeImage(imagePath: path, caption: caption))
            }
        }
        
        regex2.enumerateMatches(in: text, range: NSMakeRange(0, text.utf16.count)) { match, _, _ in
            guard let match = match else { return }
            let range1 = Range(match.range(at: 1), in: text)!
            let caption = String(text[range1]).trimmingCharacters(in: .whitespacesAndNewlines)
            let range2 = Range(match.range(at: 2), in: text)!
            let path = String(text[range2]).trimmingCharacters(in: .whitespacesAndNewlines)
            images.append(RecipeImage(imagePath: path, caption: caption))
        }
        
        return images
    }
    
    // find a date in the markdown file with a key
    private static func findDate(for key: String, in lines: [String]) -> (date: Date?, index: Int?) {
        let dateString = findValue(for: [key], in: lines)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let dateStringString = dateString.value {
            return (dateFormatter.date(from: dateStringString), dateString.index)
        } else {
            return (nil, nil)
        }
    }
    
    // format a date back for the yaml header
    private static func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    /// find out what language the markdown file is in
    private static func findLanguage(in lines: [String]) -> RecipeLanguage {
        if lines.firstIndex(where: { $0 == "## Zutaten" }) != nil {
            return .german
        } else {
            return .english
        }
    }
    
    /// find out if there is a number in a string
    private static func containsNumber(in input: String) -> Bool {
        for character in input {
            if character.isNumber {
                return true
            }
        }
        return false
    }
    
    
    /// sanitize any filename by removing ":/?*\"<>|."
    static func sanitizeFileName(_ fileName: String) -> String {
        var sanitizedFileName = fileName
        let disallowedChars = CharacterSet(charactersIn: ":/?*\"<>|")
        sanitizedFileName = sanitizedFileName.replacingOccurrences(of: ".", with: "")
        sanitizedFileName = sanitizedFileName.components(separatedBy: disallowedChars).joined(separator: "")
        sanitizedFileName = sanitizedFileName.replacingOccurrences(of: "/", with: "-")
        return sanitizedFileName
    }
    
    // find a title if it's not prefixed by '# '
    private static func findTitleAlternative(in lines: [String]) -> (value: String, index: Int?) {
        // the first index we start to search for the title in
        var startIndex = 0
        if let index = lines.firstIndex(where: { $0 == "---" }) {
            let searchIndex = index + 1
            if let secondIndex = lines[searchIndex...10].firstIndex(where: { $0 == "---" }) {
                startIndex = secondIndex + 1
            }
        }
        if let titleIndex = lines[startIndex...].firstIndex(where: { $0 != "" }) {
            let title = lines[titleIndex]
            return (title, titleIndex)
        }
        return ("No Title Found", nil)
    }
    
    // find a rating that is not labeled, finds any number up to 5 that is on a separate line without anything else
    private static func findRatingAlternative(in lines: [String]) -> (value: String, index: Int?) {
        let numberFormatter = NumberFormatter()
        for (index, string) in lines.enumerated() {
            if let doubleValue = numberFormatter.number(from: String(string)), doubleValue.doubleValue <= 5.0 {
                let intValue = Int(doubleValue.doubleValue.rounded(.toNearestOrAwayFromZero))
                return (value: String(intValue), index: index)
            }
        }
        return ("", nil)
    }
    
    // find any date if it's not prefixed correctly
    private static func findFirstDateIndexAndDate(in lines: [String]) -> (date: Date?, index: Int?) {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        
        for (index, string) in lines.enumerated() {
            let matches = detector?.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
            
            if let match = matches?.first {
                return (match.date, index)
            }
        }
        
        return (nil, nil)
    }
    
    /// get the pretty string for a recipe part enum
    static func getRecipePartName(for recipePart: RecipeParts) -> String {
        switch recipePart {
        case .title:
            return "Title"
        case .source:
            return "Source"
        case .categories:
            return "Categories"
        case .tags:
            return "Tags"
        case .rating:
            return "Rating"
        case .prepTime:
            return "Prep Time"
        case .cookTime:
            return "Cook Time"
        case .additionalTime:
            return "Additional Time"
        case .totalTime:
            return "Total Time"
        case .servings:
            return "Servings"
        case .ingredients:
            return "Ingredients"
        case .directions:
            return "Directions"
        case .nutrition:
            return "Nutrition"
        case .notes:
            return "Notes"
        case .date:
            return "Creation Date"
        case .remove:
            return "Delete"
        case .unknown:
            return "???"
        }
    }
    
    
}
