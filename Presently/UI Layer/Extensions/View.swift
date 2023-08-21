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
            .background(
                Rectangle()
                    .fill(.shadow(.inner(radius: 5)))
                    .foregroundColor(.gray.opacity(0.25))
            )
            .cornerRadius(15)
            .shadow(radius: 10)
    }
    
    func navigationCard(id: String, viewModel: ScrollViewModel, reader: ScrollViewProxy, maxHeight: CGFloat) -> some View {
        self.modifier(
            NavigationCardModifier(
                id: id,
                viewModel: viewModel,
                reader: reader,
                maxHeight: maxHeight
            )
        )
    }
}
