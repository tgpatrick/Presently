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
    
    func mainContentBox(material: Material = .thinMaterial, padding: CGFloat = 15) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(material)
            )
            .mask(RoundedRectangle(cornerRadius: 15))
            .shadow(radius: 5)
    }
    
    func navTitleMatchAnimation(namespace: Namespace.ID, customTitle: String? = nil) -> some View {
        self
            .allowsTightening(true)
            .matchedGeometryEffect(id: customTitle ?? "title", in: namespace)
    }
    
    func navigationCard(id: String, title: String? = nil, viewModel: ScrollViewModel, maxHeight: CGFloat, topInset: CGFloat, bottomInset: CGFloat, scrollViewReader: ScrollViewProxy) -> some View {
        self.modifier(
            NavigationCardModifier(
                id: id,
                title: title,
                viewModel: viewModel,
                maxHeight: maxHeight
            )
        )
    }
    
    func navCardSectionTitle() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            self
                .font(.title2)
                .bold()
                .padding(.leading)
            Divider()
                .background(Color.primary)
        }
        .padding(.bottom, 5)
    }
    
    func shiftingGlassBackground() -> some View {
        self
            .background(ShiftingBackground())
            .background(.ultraThinMaterial)
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
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func symbolTransitionIfAvailable() -> some View {
        if #available(iOS 17.0, *) {
            self.contentTransition(.symbolEffect(.replace))
        } else {
            self
        }
    }
}
