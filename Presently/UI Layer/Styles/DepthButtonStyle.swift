//
//  DepthButtonStyle.swift
//  Presently
//
//  Created by Thomas Patrick on 8/7/23.
//

import SwiftUI

struct DepthButtonStyle: ButtonStyle {
    let shape: AnyShape
    let backgroundColor: Color
    let shadowRadius: CGFloat
    let padding: CGFloat
    
    init(shape: any Shape = Capsule(), backgroundColor: Color = Color(.accentBackground), shadowRadius: CGFloat = 10, padding: CGFloat = 5) {
        self.shape = AnyShape(shape)
        self.backgroundColor = backgroundColor
        self.shadowRadius = shadowRadius
        self.padding = padding + 5
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        ZStack {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.92 : 1)
        }
        .padding(padding)
        .background(
            shape
                .fill(.shadow(.inner(radius: configuration.isPressed ? 0 : 5)))
                .foregroundColor(backgroundColor)
                .overlay {
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color.clear
                            ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .overlay {
                    if configuration.isPressed {
                        Color.black.opacity(0.15)
                    }
                }
                .clipShape(shape)
                .shadow(radius: configuration.isPressed ? 0.5 : shadowRadius)
        )
        .scaleEffect(configuration.isPressed ? 0.925 : 1)
        .animation(.easeOut(duration: configuration.isPressed ? 0 : 0.25), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        ShiftingBackground().ignoresSafeArea()
        Button {} label: {
            Text("Test!")
                .font(.title)
                .bold()
        }
        .buttonStyle(DepthButtonStyle())
    }
}
