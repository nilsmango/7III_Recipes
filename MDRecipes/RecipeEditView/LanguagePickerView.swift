//
//  FirstSectionView.swift
//  MDRecipes
//
//  Created by Simon Lang on 29.03.23.
//

import SwiftUI

struct LanguagePickerView: View {
    @Binding var language: RecipeLanguage
    
    var body: some View {
        
            Picker("Recipe Language", selection: $language) {
                            ForEach(RecipeLanguage.allCases) { language in
                                Text(language.rawValue.capitalized)
                            }
                        }

        
    }
}

struct LanguagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        LanguagePickerView(language: .constant(Recipe.sampleData[0].data.language))
    }
}
