//
//  AssignedPersonView.swift
//  Presently
//
//  Created by Thomas Patrick on 9/9/23.
//

import SwiftUI

struct AssignedPersonNavItem: NavItemView {
    var id: String = UUID().uuidString
    let title = "Your assigned person"
    @Namespace var namespace: Namespace.ID
    @ObservedObject var viewModel: ScrollViewModel
    private let assignedPerson: Person
    
    init(viewModel: ScrollViewModel) {
        self.viewModel = viewModel
        self.assignedPerson = viewModel.assignedPerson()
    }
    
    func closedView() -> AnyView {
        VStack {
            Text("Your Assignment")
                .font(.title2)
                .bold()
            Button {
                viewModel.focus(id)
            } label: {
                VStack {
                    Text(assignedPerson.name)
                        .font(.title)
                        .bold()
                        .navTitleMatchAnimation(namespace: namespace)
                    
                    HStack {
                        Text("Profile")
                        Image(systemName: "chevron.forward")
                            .bold()
                    }
                    .foregroundStyle(Color(.accent))
                }
            }
            .buttonStyle(NavListButtonStyle())
            .padding()
        }
        .fillHorizontally()
        .asAnyView()
    }
    
    func openView() -> AnyView {
        PersonView(viewModel: viewModel, person: assignedPerson, namespace: namespace)
        .asAnyView()
    }
}

struct AssignedPersonView_Previews: PreviewProvider {
    static var viewModel = ScrollViewModel()
    
    static var previews: some View {
        NavigationScrollView(viewModel: viewModel, items: [
            AssignedPersonNavItem(viewModel: viewModel)
        ])
    }
}
