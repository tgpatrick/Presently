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
    let topInset: CGFloat
    let bottomInset: CGFloat
    private let transitionTime: Double = 0.3
    @State private var maxSwipeOffset: CGFloat = 50
    @State private var swipeOffset: CGFloat = 0
    @State private var dismissSwipeDistance: CGFloat = 0
    @State private var backButtonOpacity: Double = 1
    @State private var unexpandedHeight: CGFloat = 0
    @State private var minimumHeight: CGFloat = 0
    private var isTransitioning: Bool {
        viewModel.focusedId == id && !viewModel.focusedExpanded
    }
    private var isOpen: Bool {
        viewModel.focusedId == id && viewModel.focusedExpanded
    }
    
    func body(content: Content) -> some View {
        if viewModel.focusedId == nil || viewModel.focusedId == id {
            VStack(alignment: .leading) {
                if let title {
                    if viewModel.focusedId == nil {
                        Text(title)
                    } else {
                        Text(" ")
                    }
                }
                ZStack {
                    content
                    if isOpen {
                        VStack {
                            HStack {
                                Button {
                                    viewModel.close(id)
                                } label: {
                                    Image(systemName: "chevron.backward")
                                        .padding(.horizontal, 2)
                                }
                                .buttonStyle(DepthButtonStyle(shape: Circle()))
                                .offset(x: swipeOffset)
                                .opacity(backButtonOpacity)
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
                .fillHorizontally()
                .frame(minHeight: isOpen ? (minimumHeight == 0 ? maxHeight : minimumHeight) : 0)
                .mainContentBox()
                .padding(.top, viewModel.focusedId == id ? topInset : 0)
                .padding(.bottom, viewModel.focusedId == id ? bottomInset : 0)
                .id(id)
                .offset(x: isTransitioning ? maxSwipeOffset : swipeOffset)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                unexpandedHeight = geo.size.height
                                dismissSwipeDistance = geo.size.width / 2
                                maxSwipeOffset = geo.size.width / 10
                                minimumHeight = maxHeight
                            }
                    }
                )
                .disabled(isTransitioning || swipeOffset > 0)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if isOpen && value.startLocation.x < 15 {
                                if minimumHeight == 0 {
                                    minimumHeight = maxHeight
                                }
                                let percentDismissed = value.translation.width / dismissSwipeDistance
                                backButtonOpacity = 1 - percentDismissed
                                minimumHeight = max(unexpandedHeight, min(minimumHeight, maxHeight * (1 - percentDismissed)))
                                swipeOffset = maxSwipeOffset * percentDismissed
                            }
                        }
                        .onEnded { value in
                            if isOpen && value.startLocation.x < 15 {
                                if value.predictedEndTranslation.width > dismissSwipeDistance {
                                    let percentDismissed = value.predictedEndTranslation.width / dismissSwipeDistance
                                    withAnimation(.interactiveSpring()) {
                                        minimumHeight = maxHeight * (1 - percentDismissed)
                                        swipeOffset = maxSwipeOffset * percentDismissed
                                    }
                                    viewModel.close(id)
                                }
                                withAnimation(.interactiveSpring()) {
                                    backButtonOpacity = 1
                                    minimumHeight = maxHeight
                                    swipeOffset = 0
                                    viewModel.scrollTo(id, after: 0.15)
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
