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
    
    init(shape: any Shape = Capsule(), backgroundColor: Color = Color("AccentColor")) {
        self.shape = AnyShape(shape)
        self.backgroundColor = backgroundColor
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        ZStack {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.92 : 1)
        }
        .padding(10)
        .background(
            shape
                .fill(.shadow(.inner(radius: configuration.isPressed ? 0 : 5)))
                .foregroundColor(Color(.accentBackground))
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
                .shadow(radius: configuration.isPressed ? 0.5 : 10)
        )
        .scaleEffect(configuration.isPressed ? 0.925 : 1)
        .animation(.easeOut(duration: configuration.isPressed ? 0 : 0.25), value: configuration.isPressed)
    }
}

struct CapsuleButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            Button {} label: {
                Text("Test!")
                    .font(.title)
                    .bold()
            }
            .buttonStyle(DepthButtonStyle())
        }
    }
}
