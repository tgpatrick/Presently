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
    @EnvironmentObject var viewModel: ScrollViewModel
    let assignedPerson: Person
    
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
            .contextMenu {
                Button("Open") {
                    viewModel.focus(id)
                }
            } preview: {
                PersonPreview(id: assignedPerson.personId, viewModel: viewModel)
            }
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

#Preview {
    var viewModel = ScrollViewModel()
    
    return NavigationScrollView(viewModel: viewModel, items: [
        AssignedPersonNavItem(assignedPerson: testPerson2)
    ])
    .environmentObject(viewModel)
}
