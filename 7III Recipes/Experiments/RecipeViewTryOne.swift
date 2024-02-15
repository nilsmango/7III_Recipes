//
//  RecipeView.swift
//  MDRecipes
//
//  Created by Simon Lang on 17.03.23.
//

import SwiftUI

struct RecipeViewTryOne: View {
    @ObservedObject var fileManager: RecipesManager
    
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
                if let indexToRemove = floatingTimers.firstIndex(where: { $0.step == makeIndex(of: direction) }) {
                    floatingTimers.remove(at: indexToRemove)
                }
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
    @State private var floatingTimers = [DirectionTimer]()
    
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
            
            ZStack {
                List {
                    Section {
                        HStack {
                            Image(systemName: "clock")
                            Text("\(String(Parser.extractTotalTime(from: recipe.content))) min")
                            if rating != "" {
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
                        
                    }
                    
                    Section("Directions") {
                        ForEach(Parser.extractDirections(from: recipe.content, withNumbers: true), id: \.self) { direction in
                            
                            HStack {
                                if selectionChecker(direction) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                                VStack(alignment: .leading) {
                                    Text(direction)
                                        .id(makeIndex(of: direction))
                                        .strikethrough(selectionChecker(direction) ? true : false)
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
                            
//                            recipesManager.setTimesCooked(of: recipe, to: timesCooked + 1)
                            
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
                
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            ForEach(floatingTimers) { timer in
                                FloatingTimerView(targetDate: timer.targetDate, step: timer.step, running: timer.running)
                                    .padding([.top, .horizontal])
                                
                            }
                        }
                    }
                    
                }
            }
            
            
        }
        
    }
    
    func ButtonView(direction: String) -> some View {
        HStack {
            HStack {
                if !floatingTimers.contains(where: { $0.step == makeIndex(of: direction)}) {
                    Button(action: {
                        let targetDirection = directionForTimer[makeIndex(of: direction)] != "" ? directionForTimer[makeIndex(of: direction)] : direction
                        timerTrigger(of: targetDirection)
                        targetDateArray[makeIndex(of: direction)] = targetDate(of: targetDirection)
                    }) {
                        Image(systemName: "timer")
                        if timerRunningArray[makeIndex(of: direction)] {
                            Text(targetDateArray[makeIndex(of: direction)], style: .timer)
                                .monospacedDigit()
                            
                        } else {
                            let timerDirection = directionForTimer[makeIndex(of: direction)]
                            let timerTime = Parser.extractTimerInMinutes(from: timerDirection.isEmpty ? direction : timerDirection)
                            let timeText = Parser.formatTime(timerTime)
                            Text(timeText)
                                .monospacedDigit()
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
                    let directionIndex = makeIndex(of: direction)
                    let timerMinutes: Double
                    if directionForTimer[directionIndex] == "" {
                        timerMinutes = Parser.extractTimerInMinutes(from: direction)
                    } else {
                        timerMinutes = Parser.extractTimerInMinutes(from: directionForTimer[directionIndex])
                    }
                    
                    let stepperValue: Double
                    if timerMinutes >= 25 {
                        stepperValue = -5.0
                    } else if timerMinutes >= 12 {
                        stepperValue = -2.0
                    } else if timerMinutes >= 2{
                        stepperValue = -1.0
                    } else {
                        stepperValue = 0.0
                    }
                    
                    let newTimerMinutes = timerMinutes + stepperValue
                    directionForTimer[directionIndex] = "\(directionIndex) \(newTimerMinutes) min"
                    
                }) {
                    Image(systemName: "minus.circle")
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    let directionIndex = makeIndex(of: direction)
                    let timerMinutes: Double
                    if directionForTimer[directionIndex] == "" {
                        timerMinutes = Parser.extractTimerInMinutes(from: direction)
                    } else {
                        timerMinutes = Parser.extractTimerInMinutes(from: directionForTimer[directionIndex])
                    }
                    
                    let stepperValue: Double
                    if timerMinutes >= 20 {
                        stepperValue = 5.0
                    } else if timerMinutes >= 10 {
                        stepperValue = 2.0
                    } else {
                        stepperValue = 1.0
                    }
                    
                    let newTimerMinutes = timerMinutes + stepperValue
                    directionForTimer[directionIndex] = "\(directionIndex) \(newTimerMinutes) min"
                    
                }) {
                    Image(systemName: "plus.circle")
                }
                .buttonStyle(.bordered)
            } else {
                // activate / deactivate floating timer
                if let indexToRemove = floatingTimers.firstIndex(where: { $0.step == makeIndex(of: direction) }) {
                    
                    Button(action: {
                        // stop timer and remove
                        let targetDirection = directionForTimer[makeIndex(of: direction)] != "" ? directionForTimer[makeIndex(of: direction)] : direction
                        timerTrigger(of: targetDirection)
                        targetDateArray[makeIndex(of: direction)] = targetDate(of: targetDirection)
                        floatingTimers.remove(at: indexToRemove)
                    }) {
                        Image(systemName: "stop.circle")
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        floatingTimers.remove(at: indexToRemove)
                    }) {
                        Image(systemName: "arrow.up.left.circle")
                    }
                    .buttonStyle(.bordered)
                } else {
                    
                    Button(action: {
//                        let newTimer = DirectionTimer(targetDate: targetDateArray[makeIndex(of: direction)], timerInMinutes: 14, step: makeIndex(of: direction), running: true, id: direction.id)
//                        floatingTimers.append(newTimer)
                    }) {
                        Image(systemName: "arrow.down.right.circle")
                    }
                    .buttonStyle(.bordered)
                }
                
            }
            
        }
    }
}

struct RecipeViewTryOne_Previews: PreviewProvider {
    static var previews: some View {
     
        RecipeViewTryOne(fileManager: RecipesManager(), recipe: MarkdownFile.sampleData.last!)
        
        
    }
}
