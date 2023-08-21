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
                .scaleEffect(configuration.isPressed ? 0.92 : 1)
        }
        .padding(padding)
        .background(
            Capsule()
                .fill(.shadow(.inner(radius: configuration.isPressed ? 0 : 5)))
                .foregroundColor(.accentColor)
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
                .clipShape(Capsule())
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
                    .padding()
            }
            .buttonStyle(CapsuleButtonStyle())
        }
    }
}
