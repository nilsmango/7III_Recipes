//
//  SegmentsImportView.swift
//  MDRecipes
//
//  Created by Simon Lang on 07.04.23.
//

import SwiftUI

struct SegmentsImportView: View {
    @ObservedObject var importer: Importer
    
    @State private var showAlert = false
    @State private var alertSegment = RecipeSegment(part: .unknown, lines: ["no lines"])
    @Binding var recipeLanguage: RecipeLanguage
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                Text("Assign the Segments")
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .padding([.horizontal, .top])
                
                HStack {
                    Text("Recipe Language")
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.orange)
                                .opacity(0.2)
                        }
                    
                    Spacer()
                    
                    LanguagePickerView(language: $recipeLanguage)
                        .tint(.primary)
                }
                .padding()
                
                ForEach(importer.recipeSegments) { segment in
                    SegmentView(importer: importer, segment: segment, showAlert: $showAlert, alertSegment: $alertSegment)
                    }
                }
            .padding(.horizontal)
            .scrollContentBackground(.hidden)
        }
        .overlay(
            TitleAlertView(importer: importer, showAlert: $showAlert, alertSegment: alertSegment)
        )
        .background(
            .gray
            .opacity(0.1)
        )
        .background(ignoresSafeAreaEdges: .all)
    }
}

#Preview {
        SegmentsImportView(importer: Importer(), recipeLanguage: .constant(.english))
}
