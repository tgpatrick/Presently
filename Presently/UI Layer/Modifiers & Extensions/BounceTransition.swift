//
//  BounceTransition.swift
//  Presently
//
//  Created by Thomas Patrick on 8/5/23.
//

import SwiftUI

struct BounceTransitionModifier: ViewModifier {
    enum BounceTransitionState {
        case resting
        case bounceUp
        case bounceDown
    }
    
    let transition: AnyTransition
    let animation: Animation
    let transitionLength: Double
    var shouldShowView: Binding<Bool>
    let shouldBounceOnEntry: Bool
    @State var transitionState: BounceTransitionState = .resting
    let onDismiss: (() -> Void)?
    @State private var showContent: Bool
    
    init(transition: AnyTransition, animation: Animation, transitionLength: Double, shouldShowView: Binding<Bool>, shouldBounceOnEntry: Bool = false, onDismiss: (() -> Void)?) {
        self.transition = transition
        self.animation = animation
        self.transitionLength = transitionLength
        self.shouldShowView = shouldShowView
        self.shouldBounceOnEntry = shouldBounceOnEntry
        self.onDismiss = onDismiss
        self.showContent = shouldShowView.wrappedValue
    }
    
    func body(content: Content) -> some View {
        Group {
            if showContent {
                content
                    .transition(transition)
                    .scaleEffect(transitionState == .bounceUp ? CGSize(width: 1.3, height: 1.3) : CGSize(width: 1, height: 1))
                    .scaleEffect(transitionState == .bounceDown ? CGSize(width: 0.7, height: 0.7) : CGSize(width: 1, height: 1))
            }
        }
        .onChange(of: shouldShowView.wrappedValue) { shouldShow in
            if !shouldShow {
                Timer.scheduledTimer(withTimeInterval: transitionLength, repeats: true) { timer in
                    switch transitionState {
                    case .resting:
                        withAnimation(.easeInOut(duration: transitionLength)) {
                            transitionState = .bounceUp
                        }
                    case .bounceUp:
                        withAnimation(.easeInOut(duration: transitionLength)) {
                            transitionState = .bounceDown
                        }
                    case .bounceDown:
                        withAnimation(animation) {
                            transitionState = .resting
                            showContent = false
                            if let onDismiss {
                                onDismiss()
                            }
                        }
                        timer.invalidate()
                    }
                }.fire()
            } else {
                if shouldBounceOnEntry {
                    withAnimation(animation) {
                        showContent = true
                    }
                    Timer.scheduledTimer(withTimeInterval: transitionLength, repeats: true) { timer in
                        switch transitionState {
                        case .resting:
                            withAnimation(.easeInOut(duration: transitionLength)) {
                                transitionState = .bounceDown
                            }
                        case .bounceDown:
                            withAnimation(.easeInOut(duration: transitionLength)) {
                                transitionState = .bounceUp
                            }
                        case .bounceUp:
                            withAnimation(.easeInOut(duration: transitionLength)) {
                                transitionState = .resting
                            }
                            timer.invalidate()
                        }
                    }
                } else {
                    withAnimation(animation) {
                        showContent = shouldShow
                    }
                }
            }
        }
    }
}

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
}
