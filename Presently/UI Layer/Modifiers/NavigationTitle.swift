//
//  NavigationTitle.swift
//  Presently
//
//  Created by Thomas Patrick on 9/23/23.
//

import SwiftUI

struct NavTitleModifier: ViewModifier {
    var namespace: Namespace.ID
    var customMatchTitle: String? = nil
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
            .navTitleMatchAnimation(namespace: namespace, customTitle: customMatchTitle)
            .fixedSize(horizontal: false, vertical: true)
            .offset(x: swipeOffset)
            .opacity(backswipeOpacity)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            originalMinX = geo.frame(in: .global).minX
                        }
                        .onChange(of: geo.frame(in: .global).minX) { _, newValue in
                            swipeOffset = max((newValue - originalMinX) * 1.5, 0)
                            let ratio = (swipeOffset / geo.size.width) * 3
                            backswipeOpacity = max(1 - ratio, 0.1)
                        }
                }
            )
    }
}
