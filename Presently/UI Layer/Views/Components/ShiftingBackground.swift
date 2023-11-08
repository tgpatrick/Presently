//
//  ShiftingBackground.swift
//  Presently
//
//  Created by Thomas Patrick on 8/3/23.
//

import SwiftUI

struct ShiftingBackground: View {
    @State private var center1: UnitPoint = UnitPoint(x: CGFloat.random(in: 0...1.5), y: CGFloat.random(in: 0...1.5))
    @State private var center2: UnitPoint = UnitPoint(x: CGFloat.random(in: 0...1.5), y: CGFloat.random(in: 0...1.5))
    @State private var endRadius: CGFloat = 1000
    
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(.primaryBackground)
                RadialGradient(colors: [
                    Color(.primaryBackground),
                    Color(.secondaryBackground),
                    Color(.primaryBackground)
                ], center: center1, startRadius: .zero, endRadius: endRadius)
                .opacity(0.4)
                .blur(radius: 5)
                RadialGradient(colors: [
                    Color(.primaryBackground),
                    Color(.secondaryBackground),
                    Color(.primaryBackground)
                ], center: center2, startRadius: .zero, endRadius: endRadius)
                .opacity(0.4)
                .blur(radius: 5)
            }
            .opacity(0.5)
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 3.9)) {
                    center1 = UnitPoint(x: CGFloat.random(in: 0...1.5), y: CGFloat.random(in: 0...1.5))
                    center2 = UnitPoint(x: CGFloat.random(in: 0...1.5), y: CGFloat.random(in: 0...1.5))
                }
            }
            .onAppear {
                endRadius = geo.size.height
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ShiftingBackground()
}
