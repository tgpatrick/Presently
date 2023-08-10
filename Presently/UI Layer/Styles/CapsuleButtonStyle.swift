//
//  CapsuleButtonStyle.swift
//  Presently
//
//  Created by Thomas Patrick on 8/7/23.
//

import SwiftUI

struct CapsuleButtonStyle: ButtonStyle {
    let padding: CGFloat
    let font: Font
    let backgroundColor: Color
    
    init(padding: CGFloat = 10, font: Font = .body, backgroundColor: Color = Color("AccentColor")) {
        self.padding = padding
        self.font = font
        self.backgroundColor = backgroundColor
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        ZStack {
            configuration.label
        }
        .padding(padding)
        .background(
            Capsule()
                .foregroundColor(.accentColor)
                .overlay {
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.clear
                            ]),
                        startPoint: configuration.isPressed ? .bottomTrailing : .topLeading,
                        endPoint: configuration.isPressed ? .topLeading : .bottomTrailing
                    )
                    .blur(radius: 5)
                    .clipShape(Capsule())
                }
                .shadow(radius: configuration.isPressed ? 0 : 10)
        )
        .opacity(configuration.isPressed ? 0.9 : 1)
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
