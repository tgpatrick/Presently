//
//  View.swift
//  Presently
//
//  Created by Thomas Patrick on 8/15/23.
//

import SwiftUI

extension View {
    func bounceTransition(transition: AnyTransition, animation: Animation, stepLength: Double = 0.25, showView: Binding<Bool>, onDismiss: (() -> Void)? = nil) -> some View {
        self.modifier(
            BounceTransitionModifier(
                transition: transition,
                animation: animation,
                transitionLength: stepLength,
                shouldShowView: showView,
                onDismiss: onDismiss)
        )
    }
    
    func mainContentBox() -> some View {
        self
            .padding()
            .background(
                Rectangle()
                    .fill(.shadow(.inner(radius: 5)))
                    .foregroundColor(.gray.opacity(0.25))
            )
            .cornerRadius(15)
    }
    
    func navigationCard(id: String, title: String? = nil, viewModel: ScrollViewModel, maxHeight: CGFloat, topInset: CGFloat, bottomInset: CGFloat, scrollViewReader: ScrollViewProxy) -> some View {
        self.modifier(
            NavigationCardModifier(
                id: id,
                title: title,
                viewModel: viewModel,
                maxHeight: maxHeight,
                topInset: topInset,
                bottomInset: bottomInset,
                scrollReader: scrollViewReader
            )
        )
    }
    
    func fillHorizontally() -> some View {
        ZStack {
            HStack {
                Spacer()
                Color.clear
                Spacer()
            }
            self
        }
    }
    
    func asAnyView() -> AnyView {
        AnyView(self)
    }
}
