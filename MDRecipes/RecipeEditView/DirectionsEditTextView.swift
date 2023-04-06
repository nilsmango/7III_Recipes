//
//  DirectionsEditTextView.swift
//  MDRecipes
//
//  Created by Simon Lang on 05.04.23.
//

import SwiftUI

struct DirectionsEditTextView: View {
        @Binding var directionsData: String
    
        @FocusState private var isFieldFocused: Bool
        
    var body: some View {
        List{
        Section(header: Text("Directions"), footer: Text("For best outcome number your steps. Example:\n1. Do this. 2. Do that. etc.")) {
            
                TextEditor(text: $directionsData)
                    .focused($isFieldFocused)
                    .frame(minHeight: 470)
                    .onAppear {
                        isFieldFocused = true
                    }
            }
        }
    }
}

struct DirectionsEditTextView_Previews: PreviewProvider {
    static var previews: some View {
        
            DirectionsEditTextView(directionsData: .constant("1. some directions\n2. some more\n\nWith some tips: don't wreck yourself\n3. Last directions\n"))
        
        
    }
}
