//
//  ShiftingBackground.swift
//  Presently
//
//  Created by Thomas Patrick on 8/3/23.
//

import SwiftUI

struct ShiftingBackground: View {
    @State var center1: UnitPoint = UnitPoint(x: CGFloat.random(in: 0...1.5), y: CGFloat.random(in: 0...1.5))
    @State var center2: UnitPoint = UnitPoint(x: CGFloat.random(in: 0...1.5), y: CGFloat.random(in: 0...1.5))
    @State var endRadius: CGFloat = .zero
    @State var timer: Timer?
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color("PrimaryColor")
                RadialGradient(colors: [
                    Color("PrimaryColor"),
                    Color("Secondary 1"),
                    Color("PrimaryColor")
                ], center: center1, startRadius: .zero, endRadius: endRadius)
                .opacity(0.5)
                RadialGradient(colors: [
                    Color("PrimaryColor"),
                    Color("Secondary 1"),
                    Color("PrimaryColor")
                ], center: center2, startRadius: .zero, endRadius: endRadius)
                .opacity(0.25)
            }
//            .onAppear {
//                endRadius = geo.size.width * 2
//                timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
//                    withAnimation(.easeInOut(duration: 2)) {
//                        center1 = UnitPoint(x: CGFloat.random(in: 0...1.5), y: CGFloat.random(in: 0...1.5))
//                        center2 = UnitPoint(x: CGFloat.random(in: 0...1.5), y: CGFloat.random(in: 0...1.5))
//                    }
//                }
//                timer?.fire()
//            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ShiftingBackground_Previews: PreviewProvider {
    static var previews: some View {
        ShiftingBackground()
    }
}
