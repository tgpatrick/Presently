//
//  NavigationTitle.swift
//  Presently
//
//  Created by Thomas Patrick on 9/23/23.
//

import SwiftUI

struct NavTitleModifier: ViewModifier {
    var namespace: Namespace.ID
    @State private var originalMinX: CGFloat = 0
    @State private var swipeOffset: CGFloat = 0
    @State private var backswipeOpacity: Double = 1
    
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .bold()
            .multilineTextAlignment(.center)
            .padding(.vertical, 7.5)
            .padding(.horizontal, 40)
            .navTitleMatchAnimation(namespace: namespace)
            .offset(x: swipeOffset)
            .opacity(backswipeOpacity)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            originalMinX = geo.frame(in: .global).minX
                        }
                        .onChange(of: geo.frame(in: .global).minX) { newValue in
                            swipeOffset = (newValue - originalMinX) * 1.5
                            backswipeOpacity = max(1 - (swipeOffset * 2) / geo.size.width, 0.1)
                        }
                }
            )
    }
}
