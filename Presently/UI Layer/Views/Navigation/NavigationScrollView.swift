//
//  JellyScrollView.swift
//  Presently
//
//  Created by Thomas Patrick on 8/11/23.
//

import SwiftUI

struct NavigationScrollView: View {
    @ObservedObject var viewModel: ScrollViewModel
    @State var items: [any NavItemView]
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
                VStack {
                    ForEach(translatedItems) { item in
                        AnyView(item.view)
                            .navigationCard(id: item.id, title: item.title, viewModel: viewModel, maxHeight: maxHeight, topInset: topInset, bottomInset: bottomInset, scrollViewReader: reader)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.top, topInset)
                .padding(.bottom, bottomInset)
                .padding(.vertical, 15)
            }
            .background {
                ShiftingBackground()
                    .opacity(0.2)
            }
            .background(
                GeometryReader { geo in
                    Color.clear.onAppear {
                        maxHeight = geo.size.height - topInset - topInset - 75
                    }
                }
            )
            .scrollDisabled(viewModel.focusedId != nil)
            .onAppear {
                viewModel.scrollViewReader = reader
            }
        }
    }
}

struct NavigationScrollView_Previews: PreviewProvider {
    static var viewModel = ScrollViewModel()
    
    static var previews: some View {
        NavigationScrollView(
            viewModel: viewModel,
            items: [
                ExchangeNavItem(viewModel: viewModel),
                NextDateNavItem(viewModel: viewModel),
                AssignedPersonNavItem(viewModel: viewModel),
                WishListNavItem(viewModel: viewModel),
                AllPeopleNavItem(viewModel: viewModel),
                TestNavItem(viewModel: viewModel)
            ],
            topInset: 10,
            bottomInset: 10)
    }
}
