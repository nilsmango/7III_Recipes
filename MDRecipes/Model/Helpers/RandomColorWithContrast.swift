//
//  ContrastingColors.swift
//  MDRecipes
//
//  Created by Simon Lang on 24.03.23.
//

import Foundation
import SwiftUI

//func randomColorWithContrastingFont() -> (backgroundColor: UIColor, fontColor: UIColor) {
//    let randomRed = CGFloat.random(in: 0...1)
//    let randomGreen = CGFloat.random(in: 0...1)
//    let randomBlue = CGFloat.random(in: 0...1)
//    let randomColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
//    
//    let luminance = (0.299 * randomRed + 0.587 * randomGreen + 0.114 * randomBlue)
//    let fontColor: UIColor = (luminance > 0.5) ? .black : .white
//    
//    return (backgroundColor: randomColor, fontColor: fontColor)
//}


func randomColorWithContrastingFont() -> (backgroundColor: Color, fontColor: Color) {
    let randomRed = Double.random(in: 0...1)
    let randomGreen = Double.random(in: 0...1)
    let randomBlue = Double.random(in: 0...1)
    let randomColor = Color(red: randomRed, green: randomGreen, blue: randomBlue, opacity: 1.0)
    
    let luminance = (0.299 * randomRed + 0.587 * randomGreen + 0.114 * randomBlue)
    let fontColor: Color = (luminance > 0.5) ? .black : .white
    
    return (backgroundColor: randomColor, fontColor: fontColor)
}
