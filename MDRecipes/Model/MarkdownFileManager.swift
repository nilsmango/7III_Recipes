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
        markdownFiles.remove(atOffsets: indexSet)
    }
    
    func move(from offset: IndexSet, to newPlace: Int) {
        markdownFiles.move(fromOffsets: offset, toOffset: newPlace)
    }
    
    /// Search and filter the recipes
    func filterTheRecipes(string: String, ingredients: [String], categories: [String]) -> [MarkdownFile] {
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
            let mappedIngredients = ingredients.map( { "- [ ] " + $0 })
            filteredRecipes = filteredRecipes.filter { recipe in
                        mappedIngredients.allSatisfy { word in
                                recipe.content.range(of: word, options: .caseInsensitive) != nil
                            }
                        }
        }
        
        // third stage: filtering the results by the categories
        
        if categories.isEmpty == false {
            
            filteredRecipes = filteredRecipes.filter { recipe in
                categories.allSatisfy { word in
                    if let contentRange = recipe.content.range(of: "Categories:.*\n", options: .regularExpression) {
                        let categoryString = String(recipe.content[contentRange])
                        return categoryString.contains(word)
                    } else {
                        return false
                    }
                }
            }
        }
        
        return filteredRecipes
        
        
        
    }
    
    
    
    
    // TODO: make this one function to find ingredients, categories, tags
    /// get a list of all categories in the recipes
    func getAllCategories() -> [String] {
        var categories = [String]()
        
        for recipe in markdownFiles {
            let content = recipe.content
            if let range = content.range(of: "Categories:.*\n", options: .regularExpression) {
                let categoryString = content[range]
                let cleanedCategories = categoryString.replacingOccurrences(of: "Categories: ", with: "").replacingOccurrences(of: "\n", with: "")
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
    
    
    
    /// get a list of all ingredients in the recipes
    func getAllIngredients() -> [String] {
        var ingredients: [String] = []
        
        let regex = try? NSRegularExpression(pattern: "- \\[ \\] ([^\\n]+)", options: .anchorsMatchLines)
        
        for recipe in markdownFiles {
            let content = recipe.content
            let matches = regex?.matches(in: content, options: [], range: NSRange(content.startIndex..<content.endIndex, in: content))
                for match in matches ?? [] {
                    if let range = Range(match.range, in: content) {
                        let almostIngredient = String(content[range]).capitalized
                        let ingredient = almostIngredient.replacingOccurrences(of: "- [ ] ", with: "")
                        if !ingredients.contains(ingredient) {
                            ingredients.append(ingredient)
                        }
                    }
            }
        }
        return ingredients
        
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
