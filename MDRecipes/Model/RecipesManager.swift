//
//  RecipesManager.swift
//  MDRecipes
//
//  Created by Simon Lang on 16.03.23.
//

import Foundation
import UIKit
import SwiftUI

class RecipesManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    // MARK: Notifications
    
    // This method will be called when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show an banner and play a sound
        completionHandler([.banner, .sound])
    }
    
    
    // MARK: TIMERS
    
    @Published var timers = [DirectionTimer]()
    
    /// to load and reload timers for new or edited recipes
    func loadTimers(for recipe: Recipe) {
        let directions = recipe.directions
        for direction in directions {
            if let index = timers.firstIndex(where: { $0.recipeTitle == recipe.title && $0.step == direction.step }) {
                timers.remove(at: index)
            }
            if direction.hasTimer {
                timers.append(DirectionTimer(targetDate: Date.distantFuture, timerInMinutes: direction.timerInMinutes, recipeTitle: recipe.title, stepString: direction.text, step: direction.step, running: .stopped, id: direction.id))
            }
        }
    }
    
    /// remove timers of deleted recipe from timer array
    private func removeTimers(of recipe: Recipe) {
        let directions = recipe.directions
        for direction in directions {
            if let index = timers.firstIndex(where: { $0.recipeTitle == recipe.title && $0.step == direction.step }) {
                timers.remove(at: index)
            }
        }
    }
    
    /// How the "+" and "-" buttons affect the timer time of the button
    func timerStepper(timer: DirectionTimer, add: Bool) {
        if let index = timers.firstIndex(where: { $0.id == timer.id }) {
            let stepperValue: Double
            if add {
                if timer.timerInMinutes >= 20 {
                    stepperValue = 5.0
                } else if timer.timerInMinutes >= 10 {
                    stepperValue = 2.0
                } else if timer.timerInMinutes >= 1 {
                    stepperValue = 1.0
                } else {
                    stepperValue = 1.0 - timer.timerInMinutes
                }
            } else {
                if timer.timerInMinutes >= 25 {
                    stepperValue = -5.0
                } else if timer.timerInMinutes >= 12 {
                    stepperValue = -2.0
                } else if timer.timerInMinutes >= 2 {
                    stepperValue = -1.0
                }   else if timer.timerInMinutes >= 0.2 {
                        stepperValue = -10/60
                } else {
                    stepperValue = 0.0
                }
            }
            let newTimerMinutes = timer.timerInMinutes + stepperValue
            timers[index].timerInMinutes = newTimerMinutes
        }
    }
    
    
    
    // Saving and loading of the timers and trash in the documents folder to keep the timers up when view gets destroyed
      func saveTimersAndTrashToDisk() {
          // New file URL to save the trash and timers to the same spot as the rest.
          let timersFileURL = recipesDirectory.appendingPathComponent("timers.data")
          let trashFileURL = recipesDirectory.appendingPathComponent("trash.data")
          
          DispatchQueue.global(qos: .background).async { [weak self] in
              guard let timers = self?.timers else { fatalError("Self out of scope!") }
              guard let data = try? JSONEncoder().encode(timers) else { fatalError("Error encoding timers data") }
              
              do {
                  let outFile = timersFileURL
                  try data.write(to: outFile)
              } catch {
                  fatalError("Couldn't write to file")
              }
              
              guard let trash = self?.trash else { fatalError("Self out of scope!") }
              guard let trashData = try? JSONEncoder().encode(trash) else { fatalError("Error encoding trash data") }
              
              do {
                  let outFile = trashFileURL
                  try trashData.write(to: outFile)
              } catch {
                  fatalError("Couldn't write to file")
              }
          }
      }
          
      func loadTimersAndTrashFromDisk() {
          // New file URL to save the trash and timers to the same spot as the rest.
          let timersFileURL = recipesDirectory.appendingPathComponent("timers.data")
          let trashFileURL = recipesDirectory.appendingPathComponent("trash.data")
          
          DispatchQueue.global(qos: .background).async { [weak self] in
              guard let timersData = try? Data(contentsOf: timersFileURL) else {
                  return
              }
              guard let jsonTimers = try? JSONDecoder().decode([DirectionTimer].self, from: timersData) else {
                  print("Trouble with loading the json timer file")
                  return
              }
              
              DispatchQueue.main.async {
                  self?.timers = jsonTimers
                  for timer in self!.timers {
                      if timer.targetDate < Date.now {
                          if let index = self!.timers.firstIndex(where: { $0.id == timer.id }) {
                              self!.timers[index].running = .stopped
                          }
                      }
                  }
              }
              
              guard let trashData = try? Data(contentsOf: trashFileURL) else {
                  return
              }
              guard let jsonTrash = try? JSONDecoder().decode([Recipe].self, from: trashData) else {
                  fatalError("Couldn't decode saved timers data")
              }
              
              DispatchQueue.main.async {
                         self?.trash = jsonTrash
                     }
              
                 }
                // update the trash
                updateTrash()
            }
    
    
   
    /// starting or stoping a timer
    /// starts and stops notification of timer and timer itself
    func toggleTimer(timer: DirectionTimer) {
        if let index = timers.firstIndex(where: { $0.id == timer.id }) {
            if timer.running == .running {
                // stop timer
                timers[index].running = .stopped
                
                
            } else if timer.running == .stopped {
                // start timer
                timers[index].targetDate = Date(timeIntervalSinceNow: TimeInterval(timer.timerInMinutes * 60))
                timers[index].running = .running
                

            } else if timer.running == .alarm {
                timers[index].running = .stopped
            }
            
            
        } else {
            print("Couldn't find timer")
        }
    }
    
    func alarm(for timer: DirectionTimer) {
        if let index = timers.firstIndex(where: { $0.id == timer.id }) {
            timers[index].running = .alarm
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
//                if self.timers[index].running == .alarm {
//                    self.timers[index].running = .stopped
//                }
//                
//            }
        } else {
            print("Couldn't find timer")
        }
    }
    
    
    
    
    // MARK: TRASH
    // The trash gets written to a json file like the timers. Above.
    
    @Published var trash = [Recipe]()
    
    /// remove all recipes from the trash that have been in here more than 60 days, also delete the images from the recipe from disk
    private func updateTrash() {
        let calendar = Calendar.current
        let currentDate = Date.now
        let daysAgo = -60
        let cutOffDate = calendar.date(byAdding: .day, value: daysAgo, to: currentDate)!
        
        // delete the images
        let filesWillBeRemoved = trash.filter { $0.updated < cutOffDate }
        
        for file in filesWillBeRemoved {
            for image in file.images {
                deleteImage(imagePath: image.imagePath)
            }
        }
        
        // filtering to only keep the younger than 60 days recipes
        trash = trash.filter { $0.updated >= cutOffDate }
        
    }
    
    
    // TODO: save the trash array Recipes to the filemanager + Recipe Trash, + loadTrash from there as well.
    
    // MARK: RECIPES
    
    @Published var recipes = [Recipe]()
    
    /// The document directory
    let recipesDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    /// Loading all Markdown files in the chosen directory and making them into recipes and adding them to our recipes array
    func loadMarkdownFiles() {
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: recipesDirectory, includingPropertiesForKeys: nil)
            let markdownFiles = directoryContents.filter { $0.pathExtension == "md" }
            for markdownFile in markdownFiles {
                let content = try String(contentsOf: markdownFile)
                self.recipes.append(Parser.makeRecipeFromString(string: content).recipe)
            }
        } catch {
            print("Error loading Markdown files: \(error.localizedDescription)")
        }
    }
    
    
    /// Update a recipe in the Markdown file as well the recipes array
    func updateRecipe(updatedRecipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == updatedRecipe.id }) {
            // Update the recipe in the array
            recipes[index] = updatedRecipe
            
            // Save the updated recipe to Markdown files
            saveRecipeAsMarkdownFile(recipe: updatedRecipe)
            
        }
    }
    
    // TODO: make this private once I don't use fake recipes any more
    func saveRecipeAsMarkdownFile(recipe: Recipe) {
        let markdownFile = Parser.makeMarkdownFromRecipe(recipe: recipe)
        
        let fileURL = recipesDirectory.appendingPathComponent(markdownFile.name).appendingPathExtension("md")
        do {
            try markdownFile.content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error saving updated Markdown file for recipe \(recipe.title): \(error.localizedDescription)")
        }
    }
    
    // TODO: delete this once we don't use fake recipes any more
    func createMarkdownFile(name: String, content: String) {
        recipes.append(Parser.makeRecipeFromString(string: content).recipe)
    }
    
    /// deleting only the markdown file of a recipe
    private func deleteMarkdownFile(recipeTitle: String) {
        let sanitizedTitle = Parser.sanitizeFileName(recipeTitle)
        let fileName = "\(sanitizedTitle).md"
        let fileURL = recipesDirectory.appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Error deleting Markdown file for recipe with name \(recipeTitle): \(error.localizedDescription)")
        }
    }
    
    /// deleting both Recipe and the corresponding Markdown File
    func delete(at indexSet: IndexSet, filteringCategory: String = "") {
        
        // find the id for later removing the markdown
        let idsToDelete = indexSet.map { filterTheRecipes(string: "", ingredients: [], categories: filteringCategory.isEmpty ? [] : [filteringCategory], tags: [])[$0].id }
        
        // we use the titles to remove the Markdown files later on
        var recipeTitles = [String]()
        
        for id in idsToDelete {
            // adding the titles to the recipe titles
            if let title = recipes.first(where: { $0.id == id })?.title {
                recipeTitles.append(title)
            }
        }
        
        // Delete the Markdown files
        recipeTitles.forEach(deleteMarkdownFile)
        
        // Remove the timer of the recipes
        var recipesToDelete = indexSet.map { filterTheRecipes(string: "", ingredients: [], categories: filteringCategory.isEmpty ? [] : [filteringCategory], tags: [])[$0] }
        recipesToDelete.forEach(removeTimers)
        
        // Update the updated date in the deleted recipes to the trash array
        let currentDate = Date.now
        for (index, _) in recipesToDelete.enumerated() {
            recipesToDelete[index].updated = currentDate
        }
        trash.append(contentsOf: recipesToDelete)
        
        // Remove the Recipe from the Recipes Arrays
        recipes.removeAll(where: { idsToDelete.contains($0.id) })
        
    }
    
    /// update an edited recipe
    func updateEditedRecipe(recipe: Recipe, data: Recipe.Data) {
        
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else {
            fatalError("Couldn't find recipe index in array")
        }
        
        // ad no category to all recipes without a category
        var categories = data.categories
        if categories.isEmpty {
            categories = ["No Category"]
        }
        
        // check if title was changed, delete markdown file if it was, also check if new title is unique
        var newTitle = data.title
        
        if recipe.title != data.title {
            deleteMarkdownFile(recipeTitle: recipe.title)
            
            // change title if already in the recipes or if ""!
            while recipes.contains(where: { $0.title == newTitle }) || newTitle.trimmingCharacters(in: .whitespaces) == "" {
                newTitle += "2"
            }
        }
        
        // update recipe in the recipes array
        let newRecipeData = Recipe.Data(title: newTitle,
                               source: data.source,
                               categories: categories,
                               tags: data.tags,
                               rating: data.rating,
                               prepTime: data.prepTime,
                               cookTime: data.cookTime,
                               additionalTime: data.additionalTime,
                               totalTime: data.totalTime,
                               servings: data.servings,
                               timesCooked: data.timesCooked,
                               ingredients: data.ingredients,
                               directions: Parser.reParsingDirections(directions: data.directions), // re-parsing directions to find all the new timer from edits in the list.
                               nutrition: data.nutrition,
                               notes: data.notes,
                               oldImages: updatingCleaningAndParsingImages(oldImages: data.oldImages, newImages: data.dataImages, recipeTitle: data.title),
                               date: data.date,
                               updated: Date.now,
                               language: data.language)
        
        recipes[index].update(from: newRecipeData)
        
        // update the Markdown File on disk from updated recipe
        saveRecipeAsMarkdownFile(recipe: recipes[index])
        
        // update our timers
        loadTimers(for: recipes[index])
        
    }
    
    
    /// save a new recipe
    func saveNewRecipe(newRecipeData: Recipe.Data) {
        
        // ad no category to all recipes without a category
        var categories = newRecipeData.categories
        if categories.isEmpty {
            categories = ["No Category"]
        }
        
        // check if new title is unique and not empty
        var newTitle = newRecipeData.title
        
        // change title if already in the recipes or if ""!
        while recipes.contains(where: { $0.title == newTitle }) || newTitle.trimmingCharacters(in: .whitespaces) == "" {
            newTitle += "2"
        }
        
        
        let newRecipe = Recipe(title: newTitle,
                               source: newRecipeData.source,
                               categories: categories,
                               tags: newRecipeData.tags,
                               rating: newRecipeData.rating,
                               prepTime: newRecipeData.prepTime,
                               cookTime: newRecipeData.cookTime,
                               additionalTime: newRecipeData.additionalTime,
                               totalTime: newRecipeData.totalTime,
                               servings: newRecipeData.servings,
                               timesCooked: newRecipeData.timesCooked,
                               ingredients: newRecipeData.ingredients,
                               directions: Parser.reParsingDirections(directions: newRecipeData.directions), // re-parsing directions to find all the new timer from edits in the list.
                               nutrition: newRecipeData.nutrition,
                               notes: newRecipeData.notes,
                               images: updatingCleaningAndParsingImages(oldImages: newRecipeData.oldImages, newImages: newRecipeData.dataImages, recipeTitle: newRecipeData.title),
                               date: newRecipeData.date,
                               updated: Date.now,
                               language: newRecipeData.language)
        
        
        // save the new recipe in the recipes Array
        recipes.append(newRecipe)
        
        // save the recipe as a Markdown File on disk
        saveRecipeAsMarkdownFile(recipe: newRecipe)
        
        // update the timers
        loadTimers(for: newRecipe)
    }
    
    /// make a duplication of the recipe
    func duplicateRecipe(recipe: Recipe) -> String {
        let newTitle = recipe.title + " Variation \(Int.random(in: 0...99))\(randomLetter())\(randomLetter())"
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            // change the OG recipe to a version
            var recipeVersion = recipe
            recipeVersion.title = newTitle
            recipes[index] = recipeVersion
            
            // append the old recipe with a new id
            var oldRecipe = recipe
            oldRecipe.id = UUID()
            recipes.append(oldRecipe)
        } else {
            print("Couldn't find recipe to duplicate")
        }
        return newTitle
    }
    
    /// Returns a random letter
    private func randomLetter() -> Character {
        return Character(UnicodeScalar(arc4random_uniform(26) + 97)!)
    }
    
    /// Updating, cleaning up the images in both Recipe and on disk
    private func updatingCleaningAndParsingImages(oldImages: [RecipeImage], newImages: [RecipeImageData], recipeTitle: String) -> [RecipeImage] {
        // check if there are any new images in the newImages
        let newImagesInNew = newImages.filter( { $0.isOldImage == false })
        // if there are no new images we simply return the newImages converted to RecipeImages
        var recipeImages = [RecipeImage]()
        if newImagesInNew.count == 0 {
            for image in newImages {
                // using the old image path, but the maybe new caption
                if let oldRecipeImage = oldImages.first(where: { $0.id == image.id }) {
                    recipeImages.append(RecipeImage(imagePath: oldRecipeImage.imagePath, caption: image.caption))
                }
            }
        } else {
            for image in newImages {
                // using the old image path, but the maybe new caption
                if let oldRecipeImage = oldImages.first(where: { $0.id == image.id }) {
                    recipeImages.append(RecipeImage(imagePath: oldRecipeImage.imagePath, caption: image.caption))
                } else {
                    // safe the image and create the path
                    recipeImages.append(saveImage(image: image.image, caption: image.caption, recipeName: recipeTitle))
                }
            }
        }
        
        // find all the old images that are missing in the new images and remove them from disk
        let oldImagesInTheNewImages = newImages.filter { $0.isOldImage == true }
        if oldImages.count != oldImagesInTheNewImages.count {
            for image in oldImages {
                if oldImagesInTheNewImages.first(where: { $0.id == image.id }) == nil {
                    deleteImage(imagePath: image.imagePath)
                }
            }
        }
        
        return recipeImages
    }
    
    
    /// Deleting an image from disk
    private func deleteImage(imagePath: String) {
        let url = URL(fileURLWithPath: imagePath)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Error deleting Markdown file for recipe with name \(imagePath): \(error.localizedDescription)")
        }
        
    }
    
    
    /// Saving a new images to disk and returns the RecipeImage
    private func saveImage(image: UIImage, caption: String, recipeName: String) -> RecipeImage {
        let recipePhotosDirectory = recipesDirectory.appendingPathComponent("RecipePhotos")
        let fileManager = FileManager.default
        // Create the RecipePhotos directory if it doesn't exist
        do {
            try fileManager.createDirectory(at: recipePhotosDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating RecipePhotos directory: \(error.localizedDescription)")
        }
        
        var sanitizedCaptionReduced = "-" + String(Parser.sanitizeFileName(caption).prefix(4)).replacingOccurrences(of: " ", with: "-")
        if sanitizedCaptionReduced.replacingOccurrences(of: "-", with: "").isEmpty {
            sanitizedCaptionReduced = ""
        }
        let cleanRecipeName = recipeName.replacingOccurrences(of: " ", with: "-")
        var fileName = "\(cleanRecipeName)\(sanitizedCaptionReduced).png"
        
        // check if file name already exists in the RecipePhotos directory and add +1 to the file name if it does
        var filePath = recipePhotosDirectory.appendingPathComponent(fileName).path
        if fileManager.fileExists(atPath: filePath) {
            // change name of file name, update file path until we don't find the path
            fileName = "\(cleanRecipeName)\(sanitizedCaptionReduced)2.png"
            var fileNumber = 2
            var foundFilePath = true
            while foundFilePath == true {
                filePath = recipePhotosDirectory.appendingPathComponent(fileName).path
                if fileManager.fileExists(atPath: filePath) == false {
                    foundFilePath = false
                } else {
                    fileNumber += 1
                    fileName = "\(cleanRecipeName)\(sanitizedCaptionReduced)\(fileNumber).png"
                }
            }
        }
        
        // Rotate the image if necessary
        var rotatedImage = image
        if image.imageOrientation != .up {
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            image.draw(in: CGRect(origin: .zero, size: image.size))
            rotatedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        }
        
        // Save each selected image to the RecipePhotos directory
        if let data = rotatedImage.pngData() {
            
            let fileURL = recipePhotosDirectory.appendingPathComponent(fileName)
            
            do {
                try data.write(to: fileURL)
                print("Image saved to: \(fileURL.path()), with caption: \(caption)")
            } catch {
                print("Error saving image: \(error.localizedDescription)")
            }
            return RecipeImage(imagePath: "\(fileURL.path())", caption: caption)
        }
        return RecipeImage(imagePath: "Couldn't save image", caption: caption)
    }
       
    
    /// restore recipe from trash
    func restoreRecipe(recipe: Recipe) {
        // save the new recipe in the recipes Array
        recipes.append(recipe)
        
        // save the recipe as a Markdown File on disk
        saveRecipeAsMarkdownFile(recipe: recipe)
        
        // update the timers
        loadTimers(for: recipe)
        
        // remove recipe from trash
        if let index = trash.firstIndex(where: { $0.id == recipe.id }) {
                trash.remove(at: index)
            }
    }
    
    
    /// move a recipe in the list
    func move(from offset: IndexSet, to newPlace: Int) {
        recipes.move(fromOffsets: offset, toOffset: newPlace)
    }
    
    
    /// sets the times Cooked of a recipe and resets the steps done and ingredients selected, also updates the Markdown file
    func setTimesCooked(of recipe: Recipe, to count: Int) {
        var updatedRecipe = recipe
        
        // set times cooked
        updatedRecipe.timesCooked = count
        
        // reset directions done
        for direction in updatedRecipe.directions {
            // find direction and update it
            if let directionIndex = updatedRecipe.directions.firstIndex(where: { $0.id == direction.id}) {
                updatedRecipe.directions[directionIndex].done = false
            }
        }
        
        // reset ingredients selected
        for ingredient in updatedRecipe.ingredients {
            // find ingredient and update it
            if let ingredientIndex = updatedRecipe.ingredients.firstIndex(where: { $0.id == ingredient.id}) {
                updatedRecipe.ingredients[ingredientIndex].selected = false
            }
        }
        
        // update recipe
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
                                ingredientsString.append(ingredient.text.lowercased())
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
        
        categories.sort()
        // put "No Category" at the end of the index
        if let index = categories.firstIndex(where: { $0 == "No Category" }) {
            categories.remove(at: index)
            categories.append("No Category")
        }
        
        return categories
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
                let cleanIngredient = ingredient.text.capitalized
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
    
    
    /// get a list of all the titles in the library
    func getTitles() -> [String] {
        recipes.map { $0.title }
    }
    
    /// get a random recipe
    func randomRecipe() -> Recipe? {
        recipes.randomElement()
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
    
    // MARK: Editing Directions
    
    /// Mapping Directions to a string for convenient editing
    func mapDirections(directions: [Direction]) -> String {
        return directions.map( { $0.text }).joined(separator: "\n")
    }
    
    /// Updating the Directions of a Recipe after editing them in a String
    func updatingDirectionsOfRecipe(directionsString: String, of recipe: Recipe) {
        // Parsing the Directions from the directions string
        let strings = directionsString.components(separatedBy: .newlines)
        let updatedDirections = Parser.directionsFromStrings(strings: strings)
        
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else {
            fatalError("Couldn't find recipe index in array")
        }
        
        // update the directions of the recipe in the recipes array
        recipes[index].directions = updatedDirections
        
        // update the Markdown File on disk from updated recipe
        saveRecipeAsMarkdownFile(recipe: recipes[index])
        
        // update our timers
        loadTimers(for: recipes[index])
        
    }
    
    // MARK: Editing Ingredients
    
    /// Updating the ingredients of a recipe after editing them
    func updatingIngredientsOfRecipe(ingredients: [Ingredient], of recipe: Recipe) {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else {
            fatalError("Couldn't find recipe index in array")
        }
        recipes[index].ingredients = ingredients
        
        // update the Markdown File on disk from updated recipe
        saveRecipeAsMarkdownFile(recipe: recipes[index])
        
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
