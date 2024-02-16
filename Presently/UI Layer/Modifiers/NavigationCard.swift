//
//  NavigationCard.swift
//  Presently
//
//  Created by Thomas Patrick on 8/15/23.
//

import SwiftUI

struct NavigationCardModifier: ViewModifier {
    let id: String
    let title: String?
    @ObservedObject var viewModel: ScrollViewModel
    let maxHeight: CGFloat
    @State private var maxSwipeOffset: CGFloat = 50
    @State private var swipeOffset: CGFloat = 0
    @State private var dismissSwipeDistance: CGFloat = 0
    @State private var backButtonOpacity: Double = 1
    @State private var unexpandedHeight: CGFloat = 1
    
    private var isTransitioning: Bool {
        viewModel.focusedId == id && !viewModel.focusedExpanded
    }
    private var isOpen: Bool {
        viewModel.focusedId == id && viewModel.focusedExpanded
    }
    private var isShowing: Bool {
        viewModel.focusedId == nil || viewModel.focusedId == id
    }
    
    func body(content: Content) -> some View {
        if isShowing {
            VStack(alignment: .leading) {
                if let title {
                    if viewModel.focusedId == nil {
                        Text(title)
                    } else {
                        Text(" ")
                    }
                }
                ZStack(alignment: .topLeading) {
                    content
                    if isOpen {
                        Button {
                            viewModel.close(id)
                        } label: {
                            Image(systemName: "chevron.backward")
                                .padding(.horizontal, 2)
                        }
                        .buttonStyle(DepthButtonStyle(shape: Circle()))
                        .offset(x: swipeOffset)
                        .opacity(backButtonOpacity)
                    }
                }
                .fillHorizontally()
                .mainContentBox()
                .padding(.vertical, viewModel.focusedId == id ? 10 : 0)
                .padding(.horizontal, viewModel.focusedId == id ? 0 : 10)
                .frame(maxHeight: maxHeight)
                .offset(x: isTransitioning ? maxSwipeOffset : swipeOffset)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                unexpandedHeight = geo.size.height
                                dismissSwipeDistance = geo.size.width / 2
                                maxSwipeOffset = geo.size.width / 10
                            }
                    }
                )
                .disabled(isTransitioning || swipeOffset > 0)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if isOpen && value.startLocation.x < 15 {
                                let percentDismissed = value.translation.width / dismissSwipeDistance
                                backButtonOpacity = 1 - percentDismissed
                                swipeOffset = maxSwipeOffset * percentDismissed
                            }
                        }
                        .onEnded { value in
                            if isOpen && value.startLocation.x < 15 {
                                if value.predictedEndTranslation.width > dismissSwipeDistance {
                                    let percentDismissed = value.predictedEndTranslation.width / dismissSwipeDistance
                                    withAnimation(.interactiveSpring()) {
                                        swipeOffset = maxSwipeOffset * percentDismissed
                                    }
                                    viewModel.close(id)
                                }
                                withAnimation(.interactiveSpring()) {
                                    backButtonOpacity = 1
                                    swipeOffset = 0
                                    viewModel.scrollTo(id)
                                }
                            }
                        }
                )
            }
            .transition(.move(edge: .leading).combined(with: .opacity))
        } else {
            Spacer().frame(height: unexpandedHeight)
        }
    }
}
