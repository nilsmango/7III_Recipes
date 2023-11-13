//
//  TitleAlertView.swift
//  MDRecipes
//
//  Created by Simon Lang on 06.11.23.
//

import SwiftUI

struct TitleAlertView: View {
    @Binding var showAlert: Bool
    @State private var showSearchStringQuestion = false
    
    var firstLine: String
    var segment: String
    
    var body: some View {
        if showAlert {
            HStack {
                VStack {
                    Group {
                        if showSearchStringQuestion {
                            Text("Do you want to add \"\(firstLine)\" to the search strings we use to find the segments?")
                        } else {
                            Text("The first line reads \"\(firstLine)\", is it part of the segment \"\(segment)\" or only the title?")
                        }
                    }
                    .foregroundColor(Color(.systemBackground))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    
                    Group {
                        if showSearchStringQuestion {
                            Button {
                                
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
                                showSearchStringQuestion = true
                            } label: {
                                Text("It's only the title")
                            }
                            
                            
                            Button {
                                showAlert = false
                            } label: {
                                Text("It's part of \"\(segment)\"")
                            }
                            
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(Color(.systemBackground))
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10)
//                        .foregroundColor(.gray)
                        .background(.ultraThinMaterial)
                }
            }
            .padding()
        }
        
    }
}

#Preview {
    TitleAlertView(showAlert: .constant(true), firstLine: "Ingredients", segment: "Ingredients")
}
