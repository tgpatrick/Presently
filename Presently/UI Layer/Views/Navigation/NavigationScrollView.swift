//
//  JellyScrollView.swift
//  Presently
//
//  Created by Thomas Patrick on 8/11/23.
//

import SwiftUI

struct NavigationScrollView: View {
    @ObservedObject var viewModel: ScrollViewModel
    @State var items: [any ScrollNavViewType]
    private var translatedItems: [ScrollNavItem] {
        var translated: [ScrollNavItem] = []
        for view in items {
            translated.append(ScrollNavItem(view, title: view.title))
        }
        return translated
    }
    var topInset: CGFloat = 0
    var bottomInset: CGFloat = 0
    @State var maxHeight: CGFloat = 0
    
    var body: some View {
        ScrollViewReader { reader in
            ScrollView(showsIndicators: false) {
                Spacer().frame(height: topInset)
                ForEach(translatedItems) { view in
                    AnyView(view.view)
                        .navigationCard(id: view.id, title: view.title, viewModel: viewModel, maxHeight: maxHeight, topInset: topInset, bottomInset: bottomInset, scrollViewReader: reader)
                        .padding()
                }
                Spacer().frame(height: bottomInset)
            }
            .background(
                GeometryReader { geo in
                    Color.clear.onAppear {
                        maxHeight = geo.size.height - topInset - bottomInset - 75
                    }
                }
            )
            .scrollDisabled(viewModel.focusedId != nil)
            .padding(.top, (viewModel.focusedId != nil && viewModel.focusedExpanded) ? topInset : 0)
            .padding(.bottom, (viewModel.focusedId != nil && viewModel.focusedExpanded) ? bottomInset : 0)
            .onAppear {
                viewModel.scrollViewReader = reader
            }
        }
    }
}

struct JellyScrollView_Previews: PreviewProvider {
    static var viewModel = ScrollViewModel()
    
    static var previews: some View {
        NavigationScrollView(
            viewModel: viewModel,
            items: [
                TestNavItem(viewModel: viewModel),
                TestNavItem(viewModel: viewModel),
                TestNavItem(viewModel: viewModel),
                TestNavItem(viewModel: viewModel),
                TestNavItem(viewModel: viewModel),
                TestNavItem(viewModel: viewModel),
                TestNavItem(viewModel: viewModel)
            ],
            topInset: 10,
            bottomInset: 10)
    }
}
