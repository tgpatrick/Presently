//
//  AssignedPersonView.swift
//  Presently
//
//  Created by Thomas Patrick on 9/9/23.
//

import SwiftUI

struct AssignedPersonView: ScrollNavViewType {
    var id: String = UUID().uuidString
    @Namespace var namespace: Namespace.ID
    @ObservedObject var viewModel: ScrollViewModel
    
    func closedView() -> AnyView {
        VStack(alignment: .leading) {
            Text("Your assigned person:")
            Button {
                viewModel.focus(id)
            } label: {
                HStack {
                    Text("Tester McTesterson")
                        .font(.title2)
                        .bold()
                        .matchedGeometryEffect(id: "name", in: namespace)
                    Image(systemName: "chevron.forward")
                }
                .foregroundColor(.primary)
            }
            .fillHorizontally()
            .padding(.vertical)
        }
        .asAnyView()
    }
    
    func openView() -> AnyView {
        VStack {
            Text("Tester McTesterson")
                .font(.title2)
                .bold()
                .matchedGeometryEffect(id: "name", in: namespace)
                .modifier(NavTitleModifier())
            Spacer()
        }
        .asAnyView()
    }
}

struct AssignedPersonView_Previews: PreviewProvider {
    static var viewModel = ScrollViewModel()
    
    static var previews: some View {
        NavigationScrollView(viewModel: viewModel, items: [
            AssignedPersonView(viewModel: viewModel)
        ])
    }
}