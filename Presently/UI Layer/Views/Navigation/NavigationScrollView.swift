//
//  JellyScrollView.swift
//  Presently
//
//  Created by Thomas Patrick on 8/11/23.
//

import SwiftUI

struct NavigationScrollView: View {
    @ObservedObject var viewModel: ScrollViewModel
    
    @AppStorage("CurrentExchangeID") var exchangeID: String?
    @AppStorage("CurrentPersonID") var personID: String?
    @EnvironmentObject var environment: AppEnvironment
    @StateObject var exchangeRepo = ExchangeRepository()
    @StateObject var peopleRepo = PeopleRepository()
    
    @State var items: [any NavItemView]
    private var translatedItems: [ScrollNavItem] {
        var translated: [ScrollNavItem] = []
        for view in items {
            translated.append(ScrollNavItem(view, title: view.title))
        }
        return translated
    }
    var topInset: CGFloat = 10
    var bottomInset: CGFloat = 10
    @State private var maxHeight: CGFloat = 1
    @State private var showCards = false
    
    var body: some View {
        ScrollViewReader { reader in
            ScrollView(showsIndicators: false) {
                ForEach(translatedItems) { item in
                    if showCards {
                        item.view
                            .asAnyView()
                            .navigationCard(
                                id: item.id,
                                title: item.title,
                                viewModel: viewModel,
                                maxHeight: maxHeight,
                                scrollViewReader: reader)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .bottom)))
                    }
                }
            }
            .background {
                GeometryReader { geo in
                    ShiftingBackground()
                        .opacity(0.2)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                maxHeight = geo.size.height
                                self.showCards = true
                            }
                        }
                }
            }
            .refreshable {
                await environment.refreshFromServer(exchangeRepo: exchangeRepo, peopleRepo: peopleRepo)
            }
            .scrollDisabled(viewModel.focusedId != nil)
        }
    }
}

#Preview {
    let viewModel = ScrollViewModel()
    
    return NavigationScrollView(
        viewModel: viewModel,
        items: [
            ExchangeNavItem(userName: testPerson.name, exchange: testExchange),
            NextDateNavItem(exchange: testExchange),
            AssignedPersonNavItem(assignedPerson: testPerson2),
            WishListNavItem(assignedPerson: testPerson2),
            AllPeopleNavItem(allPeople: testPeople),
            TestNavItem()
        ],
        topInset: 10,
        bottomInset: 10
    )
    .environmentObject(viewModel)
    .environmentObject(AppEnvironment())
}
