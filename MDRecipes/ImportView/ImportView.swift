//
//  ImportView.swift
//  MDRecipes
//
//  Created by Simon Lang on 02.04.23.
//

import SwiftUI

struct ImportView: View {
    @ObservedObject var fileManager: RecipesManager
    
    // edit view data
    @Binding var recipeData: Recipe.Data
    
    
    // indexes parsed
    @State private var indexes = [Int]()
    
    @State private var counter = 0
    
    @State private var newRecipe = """

What the fuck
for 5 persons
Serves 4

Ingredients
500 g sugar
20 black peas

Instructions
1. Take the sugar and make it wet.
2. Wait for 10 Min
3. Take the peas and let soak. Wait another few hours, then you might be finished.
4. Once you think you are done.
You might be finished.

Notes:
Cooking can be dangerous

"""
    
    var body: some View {
        
            VStack {
                List {
                    Section(header: Text("Paste Recipe here"), footer: Text("Make sure in the text editor above, title, ingredients and instructions are all on separate lines and ingredients and instructions are titled as such. Then press the decode button below")) {
                        TextEditor(text: $newRecipe)
                            .frame(minHeight: 370)
                        
                    }
                    
                    Section {
                        Button {
                            counter += 1
                            let parseComponents = Parser.makeRecipeFromString(string: newRecipe)
                            recipeData = parseComponents.recipe.data
                            indexes = Array(parseComponents.indexes)
                            
                        } label: {
                            Label(counter > 0 ? "Update" : "Decode", systemImage: "gearshape.2.fill")
                        }
                    }
                }
                if counter > 0 {
                    RecipeEditView(recipeData: $recipeData, fileManager: fileManager)
                }
            }
            
        
        
            
        
    }
}

struct ImportView_Previews: PreviewProvider {
    static var previews: some View {
        ImportView(fileManager: RecipesManager(), recipeData: .constant(Recipe.sampleData[0].data))
    }
}
