//
//  BounceTransition.swift
//  Presently
//
//  Created by Thomas Patrick on 8/5/23.
//

import SwiftUI

enum BounceTransitionState {
    case resting
    case bounceUp
    case bounceDown
}

struct BounceTransitionModifier: ViewModifier {
    let transition: AnyTransition
    let animation: Animation
    let transitionLength: Double
    @Binding var shouldDismiss: Bool
    @State var transitionState: BounceTransitionState = .resting
    let onDismiss: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .transition(transition)
            .scaleEffect(transitionState == .bounceUp ? CGSize(width: 1.3, height: 1.3) : CGSize(width: 1, height: 1))
            .scaleEffect(transitionState == .bounceDown ? CGSize(width: 0.7, height: 0.7) : CGSize(width: 1, height: 1))
            .onChange(of: shouldDismiss) { shouldDismiss in
                if shouldDismiss {
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
                                if let onDismiss {
                                    onDismiss()
                                }
                            }
                            timer.invalidate()
                        }
                    }.fire()
                }
            }
    }
}

extension View {
    func bounceTransition(transition: AnyTransition, animation: Animation, stepLength: Double = 0.4, shouldStartTransition: Binding<Bool>, onDismiss: (() -> Void)? = nil) -> some View {
        self.modifier(
            BounceTransitionModifier(
                transition: transition,
                animation: animation,
                transitionLength: stepLength,
                shouldDismiss: shouldStartTransition,
                onDismiss: onDismiss)
        )
    }
}
