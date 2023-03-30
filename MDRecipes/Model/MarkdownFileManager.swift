//
//  MarkdownFileManager.swift
//  MDRecipes
//
//  Created by Simon Lang on 16.03.23.
//

import Foundation
import UIKit

class MarkdownFileManager: ObservableObject {
    
    @Published var recipes = [Recipe]()
    
    /// The document directory
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    /// Loading all Markdown files in the chosen directory and making them into recipes and adding them to our recipes array
    func loadMarkdownFiles() {
        // TODO: Change that to something that makes more sense.
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            let markdownFiles = directoryContents.filter { $0.pathExtension == "md" }
            for markdownFile in markdownFiles {
                let name = markdownFile.lastPathComponent
                let content = try String(contentsOf: markdownFile)
                self.recipes.append(Parser.makeRecipeFromMarkdown(markdown: MarkdownFile(name: name, content: content)))
            }
        } catch {
            print("Error loading Markdown files: \(error.localizedDescription)")
        }
    }
    
    /// Save a new recipe as a Markdown file in the chosen directory and add it to the recipes array
    func saveMarkdownFile(recipe: Recipe) {
        recipes.append(recipe)
        
        let markdownFile = Parser.makeMarkdownFromRecipe(recipe: recipe)
        
        let fileURL = documentsDirectory.appendingPathComponent(markdownFile.name).appendingPathExtension("md")
        do {
            try markdownFile.content.write(to: fileURL, atomically: true, encoding: .utf8)
            
        } catch {
            print("Error saving Markdown file for recipe \(recipe.title): \(error.localizedDescription)")
        }
    }
    
    /// Update a recipe in the Markdown file as well the recipes array
    func updateRecipe(updatedRecipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == updatedRecipe.id }) {
            // Update the recipe in the array
            recipes[index] = updatedRecipe
            
            // Save the updated recipe to the Markdown file
            let markdownFile = Parser.makeMarkdownFromRecipe(recipe: updatedRecipe)
            
            let fileURL = documentsDirectory.appendingPathComponent(markdownFile.name).appendingPathExtension("md")
            do {
                try markdownFile.content.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("Error saving updated Markdown file for recipe \(updatedRecipe.title): \(error.localizedDescription)")
            }
        }
    }
    
    
    func createMarkdownFile(name: String, content: String) {
        recipes.append(Parser.makeRecipeFromMarkdown(markdown: MarkdownFile(name: name, content: content)))
    }
    
    
    func delete(at indexSet: IndexSet) {
        // Remove the Recipe from the Recipes Arrays
        recipes.remove(atOffsets: indexSet)
        // we have to keep our manuallySorted array up to date
        let idsToDelete = indexSet.map { recipes[$0].id }
        
        // we use the titles to remove the Markdown files later on
        var recipeTitles = [String]()
        
        for id in idsToDelete {
            let title = recipes.first(where: { $0.id == id })?.title
            recipeTitles.append(title ?? "")
        }
        
        // Delete the Markdown files
        for title in recipeTitles {
            let fileName = "\(title).md"
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("Error deleting Markdown file for recipe with title \(title): \(error.localizedDescription)")
            }
        }
    }
    
    
    
    
    
    func move(from offset: IndexSet, to newPlace: Int) {
        recipes.move(fromOffsets: offset, toOffset: newPlace)
    }
    
    
    /// set the times Cooked of a recipe, update also the Markdown file
    func setTimesCooked(of recipe: Recipe, to count: Int) {
        var updatedRecipe = recipe
        updatedRecipe.timesCooked = count
        updateRecipe(updatedRecipe: updatedRecipe)
    }
    
    /// set the note section of a recipe, update the Markdown file too
    func updateNoteSection(of recipe: Recipe, to string: String) {
        var updatedRecipe = recipe
        updatedRecipe.notes = string
        updateRecipe(updatedRecipe: updatedRecipe)
    }
    
    /// update the rating of a recipe, update the Markdown file too
    func updateRating(of recipe: Recipe, to rating: Int) {
        var updatedRecipe = recipe
        updatedRecipe.rating = "\(rating)/5"
        updateRecipe(updatedRecipe: updatedRecipe)
    }
    
    
    
    
    
    /// Search and filter the recipes
    func filterTheRecipes(string: String, ingredients: [String], categories: [String], tags: [String]) -> [Recipe] {
        var filteredRecipes = recipes
        // first is the searchString
        if string.isEmpty == false {
            if string.contains(" ") {
                let cleanArray = Parser.makeCleanArray(from: string)
                filteredRecipes = filteredRecipes.filter { recipe in
                            cleanArray.allSatisfy { word in
                                let markdownText = Parser.makeMarkdownFromRecipe(recipe: recipe).content
                                return markdownText.range(of: word, options: .caseInsensitive) != nil
                                }
                            }
                
            } else {
                filteredRecipes = filteredRecipes.filter { Parser.makeMarkdownFromRecipe(recipe: $0).content.range(of: string, options: .caseInsensitive) != nil }
            }
        }
        // second stage: filtering the result by the ingredients
        
        if ingredients.isEmpty == false {
            
            filteredRecipes = filteredRecipes.filter { recipe in
                        ingredients.allSatisfy { word in
                            // we have to also find the singular ingredients now.
                            let singularForm = String(word.dropLast())
                            var ingredientsString = ""
                            for ingredient in recipe.ingredients {
                                ingredientsString.append(ingredient.lowercased())
                            }
                            
                            return ingredientsString.contains(word.lowercased()) || ingredientsString.contains(singularForm.lowercased())
//                            let markdownText = Parser.makeMarkdownFromRecipe(recipe: recipe).content
//                            return markdownText.range(of: word, options: .caseInsensitive) != nil ||
//                                        markdownText.range(of: singularForm, options: .caseInsensitive) != nil
                            }
                        }
        }
        
        // third stage: filtering the results by the categories
        
        if categories.isEmpty == false {
            
            filteredRecipes = filteredRecipes.filter { recipe in
                categories.allSatisfy { word in
                    let categoriesString = recipe.categories.joined(separator: " ")
                    
                        return categoriesString.contains(word)
                    }
                }
            }
        
        
        // fourth stage: filtering the results by the tags
        
        if tags.isEmpty == false {
            filteredRecipes = filteredRecipes.filter { recipe in
                tags.allSatisfy { word in
                    let tagsString = recipe.tags.joined(separator: " ").lowercased()
                    return tagsString.contains(word.lowercased())
                }
            }
        }
        
        
        return filteredRecipes
    }
    
    
    
    
    // TODO: make this one function to find ingredients, categories, tags (?)
    /// get a list of all categories in the recipes
    func getAllCategories() -> [String] {
        var categories = [String]()
        
        for recipe in recipes {
            for category in recipe.categories {
                if categories.contains(category.capitalized) == false {
                    categories.append(category.capitalized)
                }
            }
        }
        return categories.sorted()
    }
    
    /// get a list of tags from the recipes
    func getAllTags() -> [String] {
        var tags = [String]()
        
        for recipe in recipes {
            for tag in recipe.tags {
                // lowercasing everything so we only get one unique tag, first one in will set the style
                if !tags.contains(where: { $0.lowercased() == tag.lowercased() }) {
                    tags.append(tag)
                }
            }
        }
        return tags.sorted()
    }
    
    
    /// get a list of all ingredients in the recipes
    func getAllIngredients() -> [String] {
        var ingredients: [String] = []
        
        for recipe in recipes {
            for ingredient in recipe.ingredients {
                let cleanIngredient = ingredient.capitalized
                let oneIngredient = String(cleanIngredient.dropLast())
                let pluralIngredient = cleanIngredient + "s"
                
                if let i = ingredients.firstIndex(of: oneIngredient) {
                    ingredients[i] = cleanIngredient
                } else if !ingredients.contains(cleanIngredient) && !ingredients.contains(pluralIngredient) {
                    ingredients.append(cleanIngredient)
                }
            }
        }
        return ingredients.sorted()
    }
    
    
    
    
    // Sorting
    
    func sortRecipes(selection: Sorting) {
        
        switch selection {
        case .standard:
            recipes.sort(by: { $0.updated < $1.updated})
        case .name:
            recipes.sort(by: { $0.title < $1.title })
        case .time:
            recipes.sort(by:  { Double(Parser.calculateTimeInMinutes(input: $0.totalTime)) < Double(Parser.calculateTimeInMinutes(input: $1.totalTime)) })
        case .rating:
            recipes.sort(by: { $0.rating > $1.rating })
        case .cooked:
            recipes.sort(by: { $0.timesCooked > $1.timesCooked })
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
