//
//  ScrollNavViewType.swift
//  Presently
//
//  Created by Thomas Patrick on 8/22/23.
//

import SwiftUI

protocol NavItemView: View, Identifiable {
    var id: String { get }
    var title: String? { get }
    var namespace: Namespace.ID { get }
    var viewModel: ScrollViewModel { get }
    func closedView() -> AnyView
    func openView() -> AnyView
}

extension NavItemView {
    var title: String? { nil }
    var isOpen: Bool {
        viewModel.focusedId == id && viewModel.focusedExpanded
    }
    
    @ViewBuilder
    var body: some View {
        ZStack {
            if !isOpen {
                closedView()
            } else {
                openView()
            }
        }
    }
    
    func openView() -> AnyView { EmptyView().asAnyView() }
}
