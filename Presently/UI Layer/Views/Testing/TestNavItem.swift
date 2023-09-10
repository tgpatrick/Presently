//
//  TestNavItem.swift
//  Presently
//
//  Created by Thomas Patrick on 8/22/23.
//

import SwiftUI

struct TestNavItem: ScrollNavViewType {
    var id: String = UUID().uuidString
//    var title: String? = "test"
    @Namespace var namespace: Namespace.ID
    @ObservedObject var viewModel: ScrollViewModel
    
    func closedView() -> AnyView { AnyView(
        VStack {
            HStack {
                Spacer()
                Text("Test Closed!")
                Spacer()
            }
            .matchedGeometryEffect(id: "title", in: namespace)
            Button {
                viewModel.focus(id)
            } label: {
                Text("Open!")
                    .bold()
                    .padding(3)
            }
            .buttonStyle(DepthButtonStyle())
            .padding()
        }
            .padding()
    )}
    
    func openView() -> AnyView { AnyView (
        HStack {
            Spacer()
            Text("Test Open!")
            Spacer()
        }
        .matchedGeometryEffect(id: "title", in: namespace)
    )}
}
