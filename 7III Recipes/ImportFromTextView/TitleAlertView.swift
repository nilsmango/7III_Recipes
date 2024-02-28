//
//  TitleAlertView.swift
//  MDRecipes
//
//  Created by Simon Lang on 06.11.23.
//

import SwiftUI

struct TitleAlertView: View {
    @ObservedObject var importer: Importer
    
    @Binding var showAlert: Bool
    var alertSegment: RecipeSegment
    
    @State private var showSearchStringQuestion = false
    
    var firstLine: String { alertSegment.lines.first ?? "Couldn't find line" }
    var segmentPart: String { alertSegment.part.rawValue.capitalized }
    
    var body: some View {
        if showAlert {
            HStack {
                VStack {
                    Group {
                        if showSearchStringQuestion {
                            Text("Do you want to add \"\(firstLine)\" to the search strings we use to find the segments?")
                        } else {
                            Text("The first line reads \"\(firstLine)\", is it part of the segment \"\(segmentPart)\" or only the title?")
                        }
                    }
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    
                    Group {
                        if showSearchStringQuestion {
                            Button {
                                // TODO: add the firstLine to the search strings and cutoff strings of the segmentPart
                                showAlert = false
                                showSearchStringQuestion = false
                            } label: {
                                Text("Yes")
                            }
                            Button {
                                showAlert = false
                                showSearchStringQuestion = false
                            } label: {
                                Text("No")
                            }
                            
                        } else {
                            Button {
                                // removing the firstLine from the segment
                                importer.removeLineFromSegment(segmentPart: alertSegment.part, line: firstLine)
                                
                                // TODO: implement adding string to the search and cutoff strings.
//                                showSearchStringQuestion = true
                                showAlert = false
                            } label: {
                                Text("It's only the title")
                            }
                            
                            
                            Button {
                                showAlert = false
                            } label: {
                                Text("It's part of \"\(segmentPart)\"")
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.primary)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color("CustomLightGray"))
//                        .background(.ultraThinMaterial)
                }
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width * 0.8)
        }
        
    }
}

#Preview {
    TitleAlertView(importer: Importer(), showAlert: .constant(true), alertSegment: RecipeSegment(part: .ingredients, lines: ["100 g peas", "200 kg walrus"]))
}
