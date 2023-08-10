//
//  ShiftingBackground.swift
//  Presently
//
//  Created by Thomas Patrick on 8/3/23.
//

import SwiftUI

struct ShiftingBackground: View {
    let testing: Bool
    @State var center1: UnitPoint = UnitPoint(x: CGFloat.random(in: 0...1.5), y: CGFloat.random(in: 0...1.5))
    @State var endRadius: CGFloat = .zero
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color("PrimaryColor")
                RadialGradient(colors: [
                    Color("PrimaryColor"),
                    Color("Secondary 1"),
                    Color("PrimaryColor")
                ], center: center1, startRadius: .zero, endRadius: endRadius)
                .opacity(0.3)
            }
            .onAppear {
                if !testing {
                    endRadius = geo.size.width * 2
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                        withAnimation(.easeInOut(duration: 2)) {
                            center1 = UnitPoint(x: CGFloat.random(in: 0...1.5), y: CGFloat.random(in: 0...1.5))
                        }
                    }.fire()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ShiftingBackground_Previews: PreviewProvider {
    static var previews: some View {
        ShiftingBackground(testing: false)
    }
}
