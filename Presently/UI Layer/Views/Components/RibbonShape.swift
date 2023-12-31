//
//  RibbonShape.swift
//  Presently
//
//  Created by Thomas Patrick on 8/4/23.
//

import SwiftUI

struct RibbonShape: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let height = geometry.size.height
                let width = geometry.size.width
                
                path.addLines([
                    CGPoint(x: width, y: height),
                    CGPoint(x: 0, y: height),
                    CGPoint(x: height / 1.75, y: height / 2),
                    CGPoint(x: 0, y: 0),
                    CGPoint(x: width, y: 0)
                ])
            }
        }
    }
}

#Preview {
    Rectangle()
        .foregroundColor(.red)
        .frame(height: 150)
        .mask(RibbonShape())
}
