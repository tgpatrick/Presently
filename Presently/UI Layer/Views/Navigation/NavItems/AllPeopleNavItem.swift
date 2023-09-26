//
//  AllPeopleView.swift
//  Presently
//
//  Created by Thomas Patrick on 9/23/23.
//

import SwiftUI

struct AllPeopleNavItem: NavItemView {
    var id: String = UUID().uuidString
    @Namespace var namespace: Namespace.ID
    @ObservedObject var viewModel: ScrollViewModel
    private let allPeople: [Person]
    @State private var focusedPerson: Person?
    
    init(viewModel: ScrollViewModel) {
        self.viewModel = viewModel
        self.allPeople = viewModel.currentPeople()
    }
    
    func closedView() -> AnyView {
        VStack {
            if viewModel.focusedId == nil {
                Text("Everyone Else")
                    .font(.title2)
                    .bold()
            }
            ForEach(allPeople) { person in
                if (person != viewModel.currentUser() && person != viewModel.assignedPerson()) && (viewModel.focusedId == nil || focusedPerson == person) {
                    Button {
                        focusedPerson = person
                        viewModel.focus(id)
                    } label: {
                        VStack {
                            HStack {
                                Text(person.name)
                                    .transition(.identity)
                                if viewModel.focusedId == nil {
                                    Spacer()
                                    Image(systemName: "chevron.forward")
                                }
                            }
                            if viewModel.focusedId == nil {
                                Divider()
                            }
                        }
                        .padding(.vertical, 2)
                        .contentShape(Rectangle())
                    }
                }
            }
            .buttonStyle(NavListButtonStyle())
        }
        .asAnyView()
    }
    
    func openView() -> AnyView {
        Group {
            if let focusedPerson {
                PersonView(viewModel: viewModel, person: focusedPerson, namespace: namespace)
            }
        }
        .asAnyView()
    }
}

struct NavListButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.primary)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

#Preview {
    var viewModel = ScrollViewModel()
    
    return NavigationScrollView(viewModel: viewModel, items: [
        AllPeopleNavItem(viewModel: viewModel)
    ])
}
