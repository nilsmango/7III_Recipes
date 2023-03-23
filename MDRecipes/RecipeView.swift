//
//  RecipeView.swift
//  MDRecipes
//
//  Created by Simon Lang on 17.03.23.
//

import SwiftUI

struct RecipeView: View {
    @ObservedObject var fileManager: MarkdownFileManager
    
    // in-App notification
    @StateObject var delegate = NotificationDelegate()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private func timerTrigger(of direction: String) {
        let step = makeIndex(of: direction)
        let targetDate = targetDate(of: direction)
        
        if !timerRunningArray[makeIndex(of: direction)] {
            
            let remainingTime = targetDate.timeIntervalSinceNow
            
            let content = UNMutableNotificationContent()
            content.title = "Timer Step \(step)"
            content.subtitle = "Step \(step) timer has reached 0!"
            content.sound = UNNotificationSound.default
            
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            let request = UNNotificationRequest(identifier: "timerFinished", content: content, trigger: trigger)
            
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error: \(error)")
                }
            }
            timerRunningArray[makeIndex(of: direction)] = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + remainingTime) {
                timerRunningArray[makeIndex(of: direction)] = false
            }
            
        } else {
            timerRunningArray[makeIndex(of: direction)] = false
            notificationCenter.removePendingNotificationRequests(withIdentifiers: ["timerFinished"])
            
        }
    }
    
    
    var recipe: MarkdownFile
    
    var rating: String { Parser.extractRating(from: recipe.content) }
    
    
    @State private var timerRunningArray = Array(repeating: false, count: 50)
    @State private var targetDateArray = Array(repeating: Date.now, count: 50)
    @State private var directionForTimer = Array(repeating: "", count: 50)
    
    private func targetDate(of direction: String) -> Date {
        Date.now.addingTimeInterval(TimeInterval(Parser.extractTimerInMinutes(from: direction) * 60))
    }
    
    private func makeIndex(of direction: String) -> Int {
        Int(String(direction.first!))!
    }
    
    @State private var selection = [String]()
    
    private func selectionChecker(_ string: String) -> Bool {
        if selection.contains(string) {
            return true
        } else {
            return false
        }
    }
    
    
    private var timesCooked: Int { Parser.extractTimesCooked(from: recipe.content) }
    
    @State private var confettiStopper = false
    
    @AppStorage("Servings") var chosenServings = 4

    var body: some View {
        
            NavigationStack {
//                ZStack {
                
                List {
                    Section {
                        HStack {
                            Image(systemName: "clock")
                            Text("\(String(Parser.extractTotalTime(from: recipe.content))) min")
                            if rating != "-" {
                                Image(systemName: "star")
                                Text(rating)
                            }
                            Spacer()
                            Image(systemName: "menucard")
                            Text(Parser.extractCategories(from: recipe.content).first!)
                        }
                        
                    }
                    Section("Servings") {
                        Stepper("\(chosenServings)", value: $chosenServings, in: 1...1000)
                    }
                    Section(header: Text("Ingredients")) {
                        ForEach(Parser.extractIngredients(from: recipe.content), id: \.self) { ingredient in
                            IngredientView(ingredient: ingredient, recipeServings: Parser.extractServings(from: recipe.content), chosenServings: chosenServings, selected: selectionChecker(ingredient))
                                .monospacedDigit()
                                .onTapGesture {
                                    if selectionChecker(ingredient) {
                                        selection.removeAll(where: { $0 == ingredient })
                                    } else {
                                        selection.append(ingredient)
                                    }
                                    
                                }
                        }
                    }
                    
                    Section("Directions") {
                        ForEach(Parser.extractDirections(from: recipe.content, withNumbers: true), id: \.self) { direction in
                            
                                HStack {
                                    if selectionChecker(direction) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                    VStack(alignment: .leading) {
                                    Text(direction).strikethrough(selectionChecker(direction) ? true : false)
                                            .onTapGesture {
                                                if selectionChecker(direction) {
                                                    selection.removeAll(where: { $0 == direction })
                                                } else {
                                                    selection.append(direction)
                                                }
                                                
                                            }
                                    if Parser.extractTimerInMinutes(from: direction) != 0.0 && !selectionChecker(direction) {
                                        
                                        ButtonView(direction: direction)
                                        
                                        
                                    }
                                }
                                
                                
                                
                            }
                            .padding(.vertical)
                            
                        }
                        
                    }
                    
                    Section("Achievements") {
                        Button(confettiStopper ? "Well done!" : "I have finished this recipe!") {
                            
                            fileManager.setTimesCooked(of: recipe, to: timesCooked + 1)
                            
                            confettiStopper = true
                        }
                        .disabled(confettiStopper)
                        
                        Text(timesCooked == 1 ? "You have cooked this meal 1 time." : "You have cooked this meal \(timesCooked) times.")
                        
                    }
                    
                    Section("Notes") {
                        Text("Notes come here")
                    }
                    
                    Section("Statistics") {
                        Text("Source of the original recipe: ")
                        
                    }
                    
                    Text(recipe.content)
                    
                }
                .listStyle(.insetGrouped)
                .navigationTitle(recipe.name)
                    
//                    VStack {
//                        HStack {
//                            Spacer()
//                            TimerViewTop(timerTime: 0.1, step: "3", timerRunning: $timerRunning)
//                                .padding()
//                        }
//                        Spacer()
//                    }
//            }
            
                
            }
        
        }
    
    func ButtonView(direction: String) -> some View {
        HStack {
            HStack {
                Button(action: {
                    if directionForTimer[makeIndex(of: direction)] != "" {
                        let newDirection = directionForTimer[makeIndex(of: direction)]
                        timerTrigger(of: newDirection)
                        targetDateArray[makeIndex(of: direction)] = targetDate(of: newDirection)
                    } else {
                        timerTrigger(of: direction)
                        targetDateArray[makeIndex(of: direction)] = targetDate(of: direction)
                    }
                    
                }) {
                    
                        Image(systemName: "timer")
                        if timerRunningArray[makeIndex(of: direction)] {
                            Text(targetDateArray[makeIndex(of: direction)], style: .timer)
                                .monospacedDigit()
                        } else {
                            if let timerDirection = directionForTimer[makeIndex(of: direction)], !timerDirection.isEmpty {
                                let timerTime = Parser.extractTimerInMinutes(from: timerDirection)
                                let timeText = Parser.formatTime(timerTime)
                                Text(timeText)
                            } else {
                                let timerTime = Parser.extractTimerInMinutes(from: direction)
                                let timeText = Parser.formatTime(timerTime)
                                Text(timeText)
                            }

                            
                        }
                    
                    }
                }
                .foregroundColor(.white)
                .buttonStyle(.borderedProminent)
            
                .onAppear() {
                    notificationCenter.requestAuthorization(options: [.alert, .sound]) { success, error in
                        if success {
                            print("All set!")
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                    
                    notificationCenter.delegate = delegate
                }
            
            if !timerRunningArray[makeIndex(of: direction)] {
                Button(action: {
                    // TODO: I need the newDirection here in the beginning, taken from the time Parser.extractTimerInMinutes(from: direction), but then use the new after?!
                    if Parser.extractTimerInMinutes(from: direction) >= 10 {
                        let stepperValue = 5.0
                        let timerString = Parser.extractTimerInMinutes(from: direction) + stepperValue
                        directionForTimer[makeIndex(of: direction)] = String(makeIndex(of: direction)) + " \(timerString) min"
                    } else {
                        let stepperValue = 1.0
                        let timerString = Parser.extractTimerInMinutes(from: direction) + stepperValue
                        directionForTimer[makeIndex(of: direction)] = String(makeIndex(of: direction)) + " \(timerString) min"
                    }
                    
                }) {
                        Image(systemName: "plus.circle")
                }
                .buttonStyle(.bordered)
            }
            
            
        }
    }
    }




struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
     
        RecipeView(fileManager: MarkdownFileManager(), recipe: MarkdownFile.sampleData.last!)
        
        
    }
}
