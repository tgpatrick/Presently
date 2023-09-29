//
//  AllPeopleView.swift
//  Presently
//
//  Created by Thomas Patrick on 9/23/23.
//

import SwiftUI

struct AllPeopleNavItem: NavItemView {
    @Environment(\.colorScheme) private var colorScheme
    var id: String = UUID().uuidString
    @Namespace var namespace: Namespace.ID
    @EnvironmentObject var environment: AppEnvironment
    @EnvironmentObject var viewModel: ScrollViewModel
    
    let allPeople: [Person]
    @State private var focusedPerson: Person?
    
    func closedView() -> AnyView {
        VStack {
            if viewModel.focusedId == nil {
                Text("Everyone Else")
                    .font(.title2)
                    .bold()
            }
            ForEach(allPeople) { person in
                if (person != environment.currentUser && person != environment.userAssignment) &&
                    (viewModel.focusedId == nil || focusedPerson == person) {
                    Button {
                        withAnimation {
                            focusedPerson = person
                            viewModel.focus(id)
                        }
                    } label: {
                        VStack {
                            HStack {
                                if person.organizer {
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxHeight: 15)
                                        .foregroundStyle(Color(colorScheme == .light ? .primaryBackground : .secondaryBackground))
                                }
                                
                                Text(person.name)
                                    .transition(.identity)
                                
                                if let currentExchange = environment.currentExchange,
                                   let recipient = environment.getPerson(id: person.recipient),
                                    currentExchange.started && !currentExchange.secret && viewModel.focusedId == nil {
                                    HStack {
                                        Image(systemName: "arrow.forward")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .padding(.vertical, 7.5)
                                        Text(recipient.name)
                                            .font(.caption)
                                    }
                                    .foregroundStyle(Color.secondary)
                                    .frame(maxHeight: 25)
                                }
                                
                                if viewModel.focusedId == nil {
                                    Spacer()
                                    
                                    if viewModel.focusedId == nil {
                                        Image(systemName: "chevron.forward")
                                    }
                                }
                            }
                            .minimumScaleFactor(0.5)
                            if viewModel.focusedId == nil {
                                Divider()
                            }
                        }
                        .padding(.vertical, 2)
                        .contentShape(Rectangle())
                        .contextMenu {
                            Button("Open") {
                                focusedPerson = person
                                viewModel.focus(id)
                            }
                        } preview: {
                            PersonPreview(id: person.personId, viewModel: viewModel)
                        }
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
            .contentShape(RoundedRectangle(cornerRadius: 15))
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
        AllPeopleNavItem(allPeople: testPeople)
    ])
    .environmentObject(viewModel)
}
