//
//  ConfettiView.swift
//  Confetti
//
//  Created by Simon Bachmann on 24.11.20.
//

import SwiftUI

public enum ConfettiType:CaseIterable, Hashable {
    
    public enum Shape {
        case circle
        case roundedCross
    }

    case shape(Shape)
    
    public var view:AnyView{
        switch self {
            
        case .shape(.roundedCross):
            return AnyView(RoundedCross())
            
        case .shape(.circle):
            return AnyView(Circle())

        }
    }
    
    public static var allCases: [ConfettiType] {
        return [.shape(.circle), .shape(.roundedCross)]
    }
}

public struct ConfettiCannon: View {
    @Binding var counter:Int
//    @Binding var num: Int
    
    @StateObject private var confettiConfig: ConfettiConfig

    @State var animate:[Bool] = []
    @State var finishedAnimationCounter = 0
    @State var firstAppear = false
    @State var error = ""
    
    /// renders configurable confetti animation
    /// - Parameters:
    ///   - counter: on any change of this variable the animation is run
    ///   - num: amount of confettis
    ///   - colors: list of colors that is applied to the default shapes
    ///   - confettiSize: size that confettis and emojis are scaled to
    ///   - rainHeight: vertical distance that confettis pass
    ///   - fadesOut: reduce opacity towards the end of the animation
    ///   - opacity: maximum opacity that is reached during the animation
    ///   - openingAngle: boundary that defines the opening angle in degrees
    ///   - closingAngle: boundary that defines the closing angle in degrees
    ///   - radius: explosion radius
    ///   - repetitions: number of repetitions of the explosion
    ///   - repetitionInterval: duration between the repetitions

    public init(counter:Binding<Int>,
                num: [Int] = [20, 55],
                confettis:[ConfettiType] = ConfettiType.allCases,
                colors:[Color] = [.blue, .red, .green, .yellow, .pink, .black],
                confettiSize:CGFloat = 10.0,
                rainHeight: CGFloat = 600.0,
                fadesOut:Bool = false,
                opacity:Double = 1.0,
                openingAngle:Angle = .degrees(60),
                closingAngle:Angle = .degrees(120),
                radius:CGFloat = 300,
                repetitions:Int = 0,
                repetitionInterval:Double = 1.0
         
    ) {
        self._counter = counter
        var shapes = [AnyView]()
        
        for confetti in confettis{
            for color in colors{
                switch confetti {
                case .shape(_):
                    shapes.append(AnyView(confetti.view.foregroundColor(color).frame(width: confettiSize, height: confettiSize, alignment: .center)))
                    
                }
            }
        }
    
        _confettiConfig = StateObject(wrappedValue: ConfettiConfig(
            num: num,
            shapes: shapes,
            colors: colors,
            confettiSize: confettiSize,
            rainHeight: rainHeight,
            fadesOut: fadesOut,
            opacity: opacity,
            openingAngle: openingAngle,
            closingAngle: closingAngle,
            radius: radius,
            repetitions: repetitions,
            repetitionInterval: repetitionInterval
        ))
    }

    public var body: some View {
        ZStack{
            ForEach(finishedAnimationCounter..<animate.count, id:\.self){ i in
                ConfettiContainer(
                    finishedAnimationCounter: $finishedAnimationCounter,
                    confettiConfig: confettiConfig
                )
            }
        }
        .onAppear(){
            firstAppear = true
        }
        .onChange(of: counter){ value in
            if firstAppear{
                for i in 0...confettiConfig.repetitions{
                    DispatchQueue.main.asyncAfter(deadline: .now() + confettiConfig.repetitionInterval * Double(i)) {
                        animate.append(false)
                        if(value < animate.count){
                            animate[value-1].toggle()
                        }
                    }
                }
            }
        }
    }
}

struct ConfettiContainer: View {
    @Binding var finishedAnimationCounter:Int
    @StateObject var confettiConfig:ConfettiConfig
    @State var firstAppear = true

    var body: some View{
        ZStack{
            ForEach(0...confettiConfig.num.randomElement()!-1, id:\.self){_ in
                ConfettiView(confettiConfig: confettiConfig)
            }
        }
        .onAppear(){
            if firstAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + confettiConfig.animationDuration) {
                    self.finishedAnimationCounter += 1
                }
                firstAppear = false
            }
        }
    }
}

struct ConfettiView: View{
    @State var location:CGPoint = CGPoint(x: 0, y: 0)
    @State var opacity:Double = 0.0
    @StateObject var confettiConfig:ConfettiConfig
    
    func getShape() -> AnyView {
        return confettiConfig.shapes.randomElement()!
    }
    
    func getColor() -> Color {
        return confettiConfig.colors.randomElement()!
    }
    
    func getSpinDirection() -> CGFloat {
        let spinDirections = CGFloat.random(in: -1.0...1.0)
        return spinDirections
    }

    var body: some View{
        ConfettiAnimationView(shape:getShape(), color:getColor(), spinDirX: getSpinDirection(), spinDirY: getSpinDirection(), spinDirZ: getSpinDirection())
            .offset(x: location.x, y: location.y)
            .opacity(opacity)
            .onAppear(){
                withAnimation(Animation.timingCurve(0.61, 1, 0.88, 1, duration: confettiConfig.explosionAnimationDuration)) {
                    opacity = confettiConfig.opacity
                    
                    let randomAngle:CGFloat
                    if confettiConfig.openingAngle.degrees <= confettiConfig.closingAngle.degrees{
                        randomAngle = CGFloat.random(in: CGFloat(confettiConfig.openingAngle.degrees)...CGFloat(confettiConfig.closingAngle.degrees))
                    }else{
                        randomAngle = CGFloat.random(in: CGFloat(confettiConfig.openingAngle.degrees)...CGFloat(confettiConfig.closingAngle.degrees + 360)).truncatingRemainder(dividingBy: 360)
                    }
                    
                    let distance = CGFloat.random(in: 0.5...1.1) * confettiConfig.radius
                    
                    location.x = (distance + 100) * cos(deg2rad(randomAngle))
                    location.y = (-distance + 120) * sin(deg2rad(randomAngle))
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + confettiConfig.explosionAnimationDuration) {
                    withAnimation(Animation.timingCurve(0.42, 0, 1, 1, duration: confettiConfig.rainAnimationDuration)) {
                        location.y += confettiConfig.rainHeight
                        opacity = confettiConfig.fadesOut ? 0 : confettiConfig.opacity
                    }
                }
            }
    }
    
    func deg2rad(_ number: CGFloat) -> CGFloat {
        return number * CGFloat.pi / 180
    }
    
}

struct ConfettiAnimationView: View {
    @State var shape: AnyView
    @State var color: Color
    @State var spinDirX: CGFloat
    @State var spinDirY: CGFloat
    @State var spinDirZ: CGFloat
    @State var firstAppear = true

    
    @State var move = false
    @State var xSpeed = Double.random(in: 0.3...3)
    @State var zSpeed = Double.random(in: 1.3...4)
    @State var anchor = CGFloat.random(in: -0.05...0.1)

    
    var body: some View {
        shape
            .foregroundColor(color)
            .rotation3DEffect(.degrees(move ? 360:0), axis: (x: spinDirX, y: spinDirY, z: 0))
            .animation(Animation.linear(duration: xSpeed).repeatCount(15, autoreverses: false), value: move)
            .rotation3DEffect(.degrees(move ? 360:0), axis: (x: 0, y: 0, z: spinDirZ), anchor: UnitPoint(x: anchor, y: anchor))
            .animation(Animation.linear(duration: zSpeed).repeatCount(3, autoreverses: false), value: move)
            .onAppear() {
                if firstAppear {
                    move = true
                    firstAppear = true
                }
            }
    }
}

class ConfettiConfig: ObservableObject {
    internal init(num: [Int], shapes: [AnyView], colors: [Color], confettiSize: CGFloat, rainHeight: CGFloat, fadesOut: Bool, opacity: Double, openingAngle:Angle, closingAngle:Angle, radius:CGFloat, repetitions:Int, repetitionInterval:Double) {
        self.num = num
        self.shapes = shapes
        self.colors = colors
        self.confettiSize = confettiSize
        self.rainHeight = rainHeight
        self.fadesOut = fadesOut
        self.opacity = opacity
        self.openingAngle = openingAngle
        self.closingAngle = closingAngle
        self.radius = radius
        self.repetitions = repetitions
        self.repetitionInterval = repetitionInterval
        self.explosionAnimationDuration = Double(radius / 1700)
        self.rainAnimationDuration = Double((rainHeight + radius) / 280)
    }
    
    @Published var num: [Int]
    @Published var shapes:[AnyView]
    @Published var colors:[Color]
    @Published var confettiSize:CGFloat
    @Published var rainHeight:CGFloat
    @Published var fadesOut:Bool
    @Published var opacity:Double
    @Published var openingAngle:Angle
    @Published var closingAngle:Angle
    @Published var radius:CGFloat
    @Published var repetitions:Int
    @Published var repetitionInterval:Double
    @Published var explosionAnimationDuration:Double
    @Published var rainAnimationDuration:Double

    
    var animationDuration:Double{
        return explosionAnimationDuration + rainAnimationDuration
    }
    
    var openingAngleRad:CGFloat{
        return CGFloat(openingAngle.degrees) * 180 / .pi
    }
    
    var closingAngleRad:CGFloat{
        return CGFloat(closingAngle.degrees) * 180 / .pi
    }
}
