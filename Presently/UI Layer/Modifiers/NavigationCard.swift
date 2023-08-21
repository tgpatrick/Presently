//
//  NavigationCard.swift
//  Presently
//
//  Created by Thomas Patrick on 8/15/23.
//

import SwiftUI

struct NavigationCardModifier: ViewModifier {
    let id: String
    @ObservedObject var viewModel: ScrollViewModel
    var reader: ScrollViewProxy
    let maxHeight: CGFloat
    private let transitionTime: Double = 0.3
    @State private var unexpandedHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        if viewModel.focusedId == nil || viewModel.focusedId == id {
            content
                .frame(minHeight: (viewModel.focusedId == id && viewModel.focusedExpanded) ? maxHeight : 0)
                .mainContentBox()
                .id(id)
                .offset(x: (viewModel.focusedId == id && !viewModel.focusedExpanded) ? 50 : 0)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                unexpandedHeight = geo.size.height
                            }
                    }
                )
                .transition(.move(edge: .leading))
        } else {
            Spacer().frame(height: unexpandedHeight)
        }
    }
}
