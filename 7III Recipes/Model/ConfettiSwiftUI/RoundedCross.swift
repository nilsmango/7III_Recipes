//
//  RoundedCross.swift
//  Confetti
//
//  Created by Simon Bachmann on 04.12.20.
//

import SwiftUI

public struct RoundedCross: Shape {
    public func path(in rect: CGRect) -> Path {
        
        let shaper = 2.7
        
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY/shaper))
        path.addQuadCurve(to: CGPoint(x: rect.maxX/shaper, y: rect.minY), control: CGPoint(x: rect.maxX/shaper, y: rect.maxY/shaper))
        path.addLine(to: CGPoint(x: rect.maxX - rect.maxX/shaper, y: rect.minY))
        
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY/shaper), control: CGPoint(x: rect.maxX - rect.maxX/shaper, y: rect.maxY/shaper))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - rect.maxY/shaper))

        path.addQuadCurve(to: CGPoint(x: rect.maxX - rect.maxX/shaper, y: rect.maxY), control: CGPoint(x: rect.maxX - rect.maxX/shaper, y: rect.maxY - rect.maxY/shaper))
        path.addLine(to: CGPoint(x: rect.maxX/shaper, y: rect.maxY))

        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - rect.maxY/shaper), control: CGPoint(x: rect.maxX/shaper, y: rect.maxY - rect.maxY/shaper))

        return path
    }
}

struct RoundedCross_Previews: PreviewProvider {
    static var previews: some View {
        RoundedCross()
            .frame(width: 200, height: 200, alignment: .center)
    }
}
