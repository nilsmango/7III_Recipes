//
//  MarkdownFileManager.swift
//  MDRecipes
//
//  Created by Simon Lang on 16.03.23.
//

import Foundation
import UIKit

class MarkdownFileManager: ObservableObject {
    
    @Published var markdownFiles = [MarkdownFile]()
    
    func loadMarkdownFiles() {
        // TODO: Change that to something that makes more sense.
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            let markdownFiles = directoryContents.filter { $0.pathExtension == "md" }
            for markdownFile in markdownFiles {
                let name = markdownFile.lastPathComponent
                let content = try String(contentsOf: markdownFile)
                self.markdownFiles.append(MarkdownFile(name: name, content: content))
            }
        } catch {
            print("Error loading Markdown files: \(error.localizedDescription)")
        }
    }
    
    func saveMarkdownFile(name: String, content: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("md")
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            self.markdownFiles.append(MarkdownFile(name: name, content: content))
        } catch {
            print("Error saving Markdown file: \(error.localizedDescription)")
        }
    }
    
    func createMarkdownFile(name: String, content: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("md")
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            self.markdownFiles.append(MarkdownFile(name: name, content: content))
        } catch {
            print("Error creating Markdown file: \(error.localizedDescription)")
        }
    }
    
    func delete(at indexSet: IndexSet) {
        
        // we have to keep our manuallySorted array up to date
        let idsToDelete = indexSet.map { markdownFiles[$0].id }
        
        
        markdownFiles.remove(atOffsets: indexSet)
        for id in idsToDelete {
            manuallySortedMarkdownFiles.removeAll(where: { $0.id == id })
        }
        
    }
    
    func move(from offset: IndexSet, to newPlace: Int) {
        markdownFiles.move(fromOffsets: offset, toOffset: newPlace)
        updateManualList()
    }
    
    /// Search and filter the recipes
    func filterTheRecipes(string: String, ingredients: [String], categories: [String], tags: [String]) -> [MarkdownFile] {
        var filteredRecipes = markdownFiles
        // first is the searchString
        if string.isEmpty == false {
            if string.contains(" ") {
                let cleanArray = makeCleanArray(from: string)
                filteredRecipes = filteredRecipes.filter { file in
                            cleanArray.allSatisfy { word in
                                    file.content.range(of: word, options: .caseInsensitive) != nil
                                }
                            }
                
            } else {
                filteredRecipes = filteredRecipes.filter { $0.content.range(of: string, options: .caseInsensitive) != nil }
            }
        }
        // second stage: filtering the result by the ingredients - which are always shown like - [ ] string
        
        if ingredients.isEmpty == false {
            
            filteredRecipes = filteredRecipes.filter { recipe in
                        ingredients.allSatisfy { word in
                            // we have to also find the singular ingredients now.
                            let singularForm = String(word.dropLast())
                                    return recipe.content.range(of: word, options: .caseInsensitive) != nil ||
                                        recipe.content.range(of: singularForm, options: .caseInsensitive) != nil
                            }
                        }
        }
        
        // third stage: filtering the results by the categories
        
        if categories.isEmpty == false {
            
            filteredRecipes = filteredRecipes.filter { recipe in
                categories.allSatisfy { word in
                    if let contentRange = recipe.content.range(of: "Categories:.*\n", options: .regularExpression) ?? recipe.content.range(of: "Kategorien:.*\n", options: .regularExpression) {
                        let categoryString = String(recipe.content[contentRange])
                        return categoryString.contains(word)
                    } else {
                        return false
                    }
                }
            }
        }
        
        // fourth stage: filtering the results by the tags
        
        if tags.isEmpty == false {
            filteredRecipes = filteredRecipes.filter { recipe in
                tags.allSatisfy { word in
                    recipe.content.range(of: word, options: .caseInsensitive) != nil
                }
            }
        }
        
        
        return filteredRecipes
    }
    
    
    
    
    // TODO: make this one function to find ingredients, categories, tags (?)
    /// get a list of all categories in the recipes
    func getAllCategories() -> [String] {
        var categories = [String]()
        
        for recipe in markdownFiles {
            let content = recipe.content
            if let range = content.range(of: "Categories:.*\n", options: .regularExpression) ?? recipe.content.range(of: "Kategorien:.*\n", options: .regularExpression) {
                let categoryString = content[range]
                let cleanedCategories = categoryString.replacingOccurrences(of: "Categories: ", with: "").replacingOccurrences(of: "Kategorien: ", with: "").replacingOccurrences(of: "\n", with: "")
                let stringArray = cleanedCategories.components(separatedBy: ", ")
                let cleanArray = stringArray.filter( { $0 != "" })
                for string in cleanArray {
                    if categories.contains(string) == false {
                        categories.append(string)
                    }
                }
            }
        }
        return categories
    }
    
    /// extract the categories from a recipe
    func extractCategories(from string: String) -> [String] {
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
    
    
    
    
    
    /// get a list of tags from the recipes
    func getAllTags() -> [String] {
        var tags = [String]()
        let regex = try! NSRegularExpression(pattern: "#\\w+")
        
        for recipe in markdownFiles {
            let content = recipe.content
            
            let results = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))

            let foundTags = results.map { String(content[Range($0.range, in: content)!]) }
            
            for tag in foundTags {
                // lowercasing everything so we only get one unique tag, first one in will set the style
                if !tags.contains(where: { $0.lowercased() == tag.lowercased() }) {
                    tags.append(tag)
                }
            }
        }
        
        
        
        return tags
    }
    
    
    /// get a list of all ingredients in the recipes
    func getAllIngredients() -> [String] {
        var ingredients: [String] = []
        
        let regex = try? NSRegularExpression(pattern: "- \\[ \\] ([^\\n]+)", options: .anchorsMatchLines)
        
        for recipe in markdownFiles {
            let content = recipe.content
            let matches = regex?.matches(in: content, options: [], range: NSRange(content.startIndex..<content.endIndex, in: content))
                for match in matches ?? [] {
                    if let range = Range(match.range, in: content) {
                        let almostIngredient = String(content[range])
                        let ingredient = extractOnlyIngredient(from: almostIngredient.replacingOccurrences(of: "- [ ] ", with: "")).capitalized
                        
                        // trying get plural form where possible and don't add the singular form (it works great this way)
                        let oneIngredient = String(ingredient.dropLast())
                        let pluralIngredient = ingredient + "s"
                        
                        if let i = ingredients.firstIndex(of: oneIngredient) {
                            ingredients[i] = ingredient
                        } else if !ingredients.contains(ingredient) && !ingredients.contains(pluralIngredient) {
                            ingredients.append(ingredient)
                        }
                    }
            }
        }
        return ingredients
    }
    
    // useful constants
    private let decimalCharacters = CharacterSet.decimalDigits
    
    private let units = ["g", "kg", "ml", "l", "dl", "hl", "cups", "cup", "tsp.", "Tbsp.", "EL", "TL", "packet", "some", "Packet", "Dose", "Kiste", "Teelöffel", "Esslöffel", "pinch", "pinches", "Eine", "Prise", "Prisen", "mg", "L", "Liter", "Ltr.", "ounce", "ounces", "approx.", "approximately", "etwa", "tablespoons", "tablespoon", "teaspoon", "teaspoons", "heaped", "clove", "cloves", "Zehe", "Zehen", "whole", "ganze", "ganz", "zum Anbraten", "wenig", "Messerspitze"]
    
    private func extractOnlyIngredient(from string: String) -> String {
        // Split the string by spaces
        let words = string.split(separator: " ")
        
        var ingredient = String()
        
        // Find all the words not containing digits and units, adding them back together.
        for word in words {
            if word.rangeOfCharacter(from: decimalCharacters) == nil && units.description.lowercased().contains(String(word).lowercased()) == false {
                ingredient = ingredient + " " + word
            }
        }
        return ingredient
    }
    
    /// extracting all ingredients from a string
    func extractIngredients(from string: String) -> [String] {
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
    
    
    func extractServings(from string: String) -> Int {
    
        if let range = string.range(of: "Servings:.*\n", options: .regularExpression) ?? string.range(of: "Portionen:.*\n", options: .regularExpression) {
            let ratingString = string[range]
            let cleanedRating = ratingString.replacingOccurrences(of: "Servings: ", with: "").replacingOccurrences(of: "Portionen: ", with: "").replacingOccurrences(of: "\n", with: "")
            return Int(cleanedRating) ?? 1
        } else {
            return 1
        }
    }
    
    
    func extractRating(from string: String) -> String {
        if let range = string.range(of: "Rating:.*\n", options: .regularExpression) ?? string.range(of: "Bewertung:.*\n", options: .regularExpression) {
            let ratingString = string[range]
            let cleanedRating = ratingString.replacingOccurrences(of: "Rating: ", with: "").replacingOccurrences(of: "Bewertung: ", with: "").replacingOccurrences(of: "\n", with: "")
            return cleanedRating
        } else {
            return "-"
        }
    }
    
    
    func extractTotalTime(from string: String) -> Int {
        var totalTime = 0
        
        if let range = string.range(of: "Total time:.*\n", options: .regularExpression) ?? string.range(of: "Gesamtzeit:.*\n", options: .regularExpression) {
            let categoryString = string[range]
            let cleanedTime = categoryString.replacingOccurrences(of: "Total time: ", with: "").replacingOccurrences(of: "Gesamtzeit: ", with: "").replacingOccurrences(of: "\n", with: "")
            totalTime = calculateTimeInMinutes(input: cleanedTime)
            }
            return totalTime
        }
    
    
    private func calculateTimeInMinutes(input: String) -> Int  {
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
        
    /// Extract the instructions from the string
    func extractDirections(from string: String, withNumbers: Bool) -> [String] {
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
    
    
    
    // Sorting
    
    var manuallySortedMarkdownFiles = [MarkdownFile]()
    
    private func updateManualList() {
            manuallySortedMarkdownFiles = markdownFiles
        }
        
        
    func sortRecipes(selection: Sorting) {
        if manuallySortedMarkdownFiles.isEmpty {
            updateManualList()
        }
        
        switch selection {
            
        case .manual:
            markdownFiles = manuallySortedMarkdownFiles
        case .name:
            markdownFiles.sort(by: { $0.name < $1.name })
        case .time:
            markdownFiles.sort(by:  { extractTotalTime(from: $0.content) < extractTotalTime(from: $1.content) })
        case .rating:
            markdownFiles.sort(by: { extractRating(from: $0.content) > extractRating(from: $1.content) })
        }
    }
    
}



// FIXME: Idea for MacOS and iOS with document chooser:
//
//import Foundation
//#if os(iOS)
//import UIKit
//#endif
//import SwiftUI
//import MobileCoreServices
//#if os(macOS)
//import Cocoa
//#endif
//
//class MarkdownFileManager {
//    var directoryURL: URL?
//
//    init(directoryURL: URL?) {
//        self.directoryURL = directoryURL
//    }
//
//    #if os(iOS)
//    func openFilePicker(onSelected: @escaping (URL?) -> Void) {
//        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePlainText as String], in: .import)
//        documentPicker.allowsMultipleSelection = false
//        documentPicker.delegate = self
//        UIApplication.shared.windows.first?.rootViewController?.present(documentPicker, animated: true, completion: nil)
//    }
//    #endif
//
//    func saveFile(_ markdownFile: MarkdownFile) {
//        guard let directoryURL = directoryURL else {
//            print("Directory URL is not set")
//            return
//        }
//
//        let fileURL = directoryURL.appendingPathComponent(markdownFile.name)
//
//        do {
//            try markdownFile.content.write(to: fileURL, atomically: true, encoding: .utf8)
//            print("Saved file at: \(fileURL)")
//        } catch {
//            print("Failed to save file: \(error.localizedDescription)")
//        }
//    }
//
//    func loadFiles() -> [MarkdownFile] {
//        guard let directoryURL = directoryURL else {
//            print("Directory URL is not set")
//            return []
//        }
//
//        do {
//            let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
//            let markdownFiles = fileURLs.filter { $0.pathExtension == "md" }.compactMap { fileURL -> MarkdownFile? in
//                let name = fileURL.lastPathComponent
//                let content = try? String(contentsOf: fileURL, encoding: .utf8)
//                return content != nil ? MarkdownFile(name: name, content: content!) : nil
//            }
//            return markdownFiles
//        } catch {
//            print("Failed to load files: \(error.localizedDescription)")
//            return []
//        }
//    }
//
//    func createFile(name: String, content: String) -> MarkdownFile? {
//        guard let directoryURL = directoryURL else {
//            print("Directory URL is not set")
//            return nil
//        }
//
//        let fileURL = directoryURL.appendingPathComponent(name)
//
//        do {
//            try content.write(to: fileURL, atomically: true, encoding: .utf8)
//            print("Created file at: \(fileURL)")
//            return MarkdownFile(name: name, content: content)
//        } catch {
//            print("Failed to create file: \(error.localizedDescription)")
//            return nil
//        }
//    }
//
//    #if os(macOS)
//    func chooseDirectory(completion: @escaping (URL?) -> Void) {
//        let openPanel = NSOpenPanel()
//        openPanel.canChooseDirectories = true
//        openPanel.canCreateDirectories = true
//        openPanel.canChooseFiles = false
//
//        if let directoryURL = directoryURL {
//            openPanel.directoryURL = directoryURL
//        }
//
//        openPanel.begin { response in
//            if response == .OK, let url = openPanel.url {
//                self.directoryURL = url
//                completion(url)
//            } else {
//                completion(nil)
//            }
//        }
//    }
//    #endif
//}
//
//#if os(iOS)
//extension MarkdownFileManager: UIDocumentPickerDelegate {
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        guard let fileURL = urls.first, fileURL.startAccessingSecurityScopedResource() else {
//            return
//        }
//
//        defer {
//            fileURL.stopAccessingSecurityScopedResource()
//        }
//
//        guard fileURL.pathExtension == "md" else {
//            print("Unsupported file type")
//            return
//        }
//
//        do {
//            let content = try String(contentsOf: fileURL, encoding: .utf8)
//            let name = fileURL.lastPathComponent
//            let markdownFile = MarkdownFile(name: name, content: content)
//            onFileOpened?(markdownFile)
//        } catch {
//            print("Failed to open file: \(error.localizedDescription)")
//        }
//    }
//
//    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//        // Do nothing
//    }
//}
//#endif



// FIXME: idea with a document chooser for iOS:

//import Foundation
//import UIKit
//
//class MarkdownFileManager {
//    var directoryURL: URL?
//
//    init(directoryURL: URL?) {
//        self.directoryURL = directoryURL
//    }
//
//    func saveFile(_ markdownFile: MarkdownFile) {
//        guard let directoryURL = directoryURL else {
//            print("Directory URL is not set")
//            return
//        }
//
//        let fileURL = directoryURL.appendingPathComponent(markdownFile.name)
//
//        do {
//            try markdownFile.content.write(to: fileURL, atomically: true, encoding: .utf8)
//            print("Saved file at: \(fileURL)")
//        } catch {
//            print("Failed to save file: \(error.localizedDescription)")
//        }
//    }
//
//    func loadFiles() -> [MarkdownFile] {
//        guard let directoryURL = directoryURL else {
//            print("Directory URL is not set")
//            return []
//        }
//
//        do {
//            let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
//            let markdownFiles = fileURLs.filter { $0.pathExtension == "md" }.compactMap { fileURL -> MarkdownFile? in
//                let name = fileURL.lastPathComponent
//                let content = try? String(contentsOf: fileURL, encoding: .utf8)
//                return content != nil ? MarkdownFile(name: name, content: content!) : nil
//            }
//            return markdownFiles
//        } catch {
//            print("Failed to load files: \(error.localizedDescription)")
//            return []
//        }
//    }
//
//    func createFile(name: String, content: String) -> MarkdownFile? {
//        guard let directoryURL = directoryURL else {
//            print("Directory URL is not set")
//            return nil
//        }
//
//        let fileURL = directoryURL.appendingPathComponent(name)
//
//        do {
//            try content.write(to: fileURL, atomically: true, encoding: .utf8)
//            print("Created file at: \(fileURL)")
//            return MarkdownFile(name: name, content: content)
//        } catch {
//            print("Failed to create file: \(error.localizedDescription)")
//            return nil
//        }
//    }
//
//    func chooseDirectory(completion: @escaping (URL?) -> Void) {
//        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
//        documentPicker.allowsMultipleSelection = false
//        documentPicker.shouldShowFileExtensions = true
//
//        documentPicker.directoryURL = directoryURL
//
//        documentPicker.didPickDocumentAt = { [weak self] url in
//            guard let self = self else { return }
//            self.directoryURL = url
//            completion(url)
//        }
//
//        documentPicker.didPickDocumentsAt = { [weak self] urls in
//            guard let self = self else { return }
//            if let url = urls.first {
//                self.directoryURL = url
//                completion(url)
//            }
//        }
//
//        documentPicker.modalPresentationStyle = .formSheet
//
//        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
//            completion(nil)
//            return
//        }
//
//        rootViewController.present(documentPicker, animated: true, completion: nil)
//    }
//}


// FIXME: Idea for macOS:

//import Foundation
//import Cocoa
//
//class MarkdownFileManager {
//    var directoryURL: URL?
//
//    init(directoryURL: URL?) {
//        self.directoryURL = directoryURL
//    }
//
//    func saveFile(_ markdownFile: MarkdownFile) {
//        guard let directoryURL = directoryURL else {
//            print("Directory URL is not set")
//            return
//        }
//
//        let fileURL = directoryURL.appendingPathComponent(markdownFile.name)
//
//        do {
//            try markdownFile.content.write(to: fileURL, atomically: true, encoding: .utf8)
//            print("Saved file at: \(fileURL)")
//        } catch {
//            print("Failed to save file: \(error.localizedDescription)")
//        }
//    }
//
//    func loadFiles() -> [MarkdownFile] {
//        guard let directoryURL = directoryURL else {
//            print("Directory URL is not set")
//            return []
//        }
//
//        do {
//            let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
//            let markdownFiles = fileURLs.filter { $0.pathExtension == "md" }.compactMap { fileURL -> MarkdownFile? in
//                let name = fileURL.lastPathComponent
//                let content = try? String(contentsOf: fileURL, encoding: .utf8)
//                return content != nil ? MarkdownFile(name: name, content: content!) : nil
//            }
//            return markdownFiles
//        } catch {
//            print("Failed to load files: \(error.localizedDescription)")
//            return []
//        }
//    }
//
//    func createFile(name: String, content: String) -> MarkdownFile? {
//        guard let directoryURL = directoryURL else {
//            print("Directory URL is not set")
//            return nil
//        }
//
//        let fileURL = directoryURL.appendingPathComponent(name)
//
//        do {
//            try content.write(to: fileURL, atomically: true, encoding: .utf8)
//            print("Created file at: \(fileURL)")
//            return MarkdownFile(name: name, content: content)
//        } catch {
//            print("Failed to create file: \(error.localizedDescription)")
//            return nil
//        }
//    }
//
//    func chooseDirectory(completion: @escaping (URL?) -> Void) {
//        let openPanel = NSOpenPanel()
//        openPanel.canChooseDirectories = true
//        openPanel.canCreateDirectories = true
//        openPanel.canChooseFiles = false
//
//        if let directoryURL = directoryURL {
//            openPanel.directoryURL = directoryURL
//        }
//
//        openPanel.begin { response in
//            if response == .OK, let url = openPanel.url {
//                self.directoryURL = url
//                completion(url)
//            } else {
//                completion(nil)
//            }
//        }
//    }
//}
