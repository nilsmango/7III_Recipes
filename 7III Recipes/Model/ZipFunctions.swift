//
//  ZipFunctions.swift
//  7III Recipes
//
//  Created by Simon Lang on 11.02.2024.
//

import Foundation
import ZIPFoundation



func handleZipFile(url: URL) throws {
        // TODO: check if it has an RecipeImages folder in the zip. 
        let destinationDirectory = FileManager.default.temporaryDirectory
        
        // Unzip the contents of the zip file
        try FileManager.default.unzipItem(at: url, to: destinationDirectory)
        
        // Do something with the contents of the unzipped files
        print("Successfully unzipped files to: \(destinationDirectory.path)")
    }
