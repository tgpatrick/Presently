//
//  TestNavItem.swift
//  Presently
//
//  Created by Thomas Patrick on 8/22/23.
//

import SwiftUI

struct TestNavItem: NavItemView {
    var id: String = UUID().uuidString
    //var title: String? = "test"
    @Namespace var namespace: Namespace.ID
    @ObservedObject var viewModel: ScrollViewModel
    
    func closedView() -> AnyView {
        VStack {
            VStack {
                Text("Testing")
                    .bold()
                    .navTitleMatchAnimation(namespace: namespace)
                Text("Open this card to perform network and storage tests")
            }
            .fillHorizontally()
            Button {
                viewModel.focus(id)
            } label: {
                Text("Open")
                    .bold()
                    .padding(3)
            }
            .buttonStyle(DepthButtonStyle())
            .padding()
        }
        .padding()
        .asAnyView()
    }
    
    func openView() -> AnyView {
        VStack {
            Text("Testing")
                .modifier(NavTitleModifier(namespace: namespace))
            TestView()
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .asAnyView()
    }
}
