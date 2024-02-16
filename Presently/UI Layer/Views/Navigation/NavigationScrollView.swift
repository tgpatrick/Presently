//
//  JellyScrollView.swift
//  Presently
//
//  Created by Thomas Patrick on 8/11/23.
//

import SwiftUI

struct NavigationScrollView: View {
    @AppStorage("CurrentExchangeID") var exchangeID: String?
    @AppStorage("CurrentPersonID") var personID: String?
    @EnvironmentObject var environment: AppEnvironment
    @EnvironmentObject var viewModel: ScrollViewModel
    @StateObject var exchangeRepo = ExchangeRepository()
    @StateObject var peopleRepo = PeopleRepository()
    
    @Binding var items: [any NavItemView]
    private var translatedItems: [ScrollNavItem] {
        var translated: [ScrollNavItem] = []
        for view in items {
            translated.append(ScrollNavItem(view, title: view.title))
        }
        return translated
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollViewReader { reader in
                ScrollView(showsIndicators: false) {
                    ForEach(translatedItems) { item in
                        item.view
                            .asAnyView()
                            .navigationCard(
                                id: item.id,
                                title: item.title,
                                viewModel: viewModel,
                                maxHeight: geo.size.height,
                                scrollViewReader: reader)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                .refreshable {
                    await environment.refreshFromServer(exchangeRepo: exchangeRepo, peopleRepo: peopleRepo)
                }
                .scrollDisabled(viewModel.focusedId != nil)
            }
        }
    }
}

#Preview {
    let viewModel = ScrollViewModel()
    
    return NavigationScrollView(
        items: .constant([
            ExchangeNavItem(userName: testPerson.name, exchange: testExchange),
            NextDateNavItem(exchange: testExchange),
            AssignedPersonNavItem(assignedPerson: testPerson2),
            WishListNavItem(assignedPerson: testPerson2),
            AllPeopleNavItem(allPeople: testPeople),
            TestNavItem()
        ])
    )
    .environmentObject(viewModel)
    .environmentObject(AppEnvironment())
}
