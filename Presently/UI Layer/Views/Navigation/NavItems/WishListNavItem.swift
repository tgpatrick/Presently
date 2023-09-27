//
//  WishListNavItem.swift
//  Presently
//
//  Created by Thomas Patrick on 9/25/23.
//

import SwiftUI

struct WishListNavItem: NavItemView {
    var id: String = UUID().uuidString
    @Namespace var namespace: Namespace.ID
    @ObservedObject var viewModel: ScrollViewModel
    private let assignedPerson: Person
    
    init(viewModel: ScrollViewModel) {
        self.viewModel = viewModel
        self.assignedPerson = viewModel.assignedPerson()
    }
    
    func closedView() -> AnyView {
        VStack {
            Text("\(assignedPerson.name)'s Wishlist")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            WishListView(wishList: assignedPerson.wishList)
        }
        .asAnyView()
    }
}
