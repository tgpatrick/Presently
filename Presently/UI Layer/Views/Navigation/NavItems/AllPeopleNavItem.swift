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
    
    let allPeople: People
    @State private var focusedPerson: Person?
    
    func closedView() -> AnyView {
        VStack {
            Text("Everyone")
                .font(.title2)
                .bold()
            
            ForEach(allPeople.sorted()) { person in
                if showNameFor(person) {
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
                                        .matchedGeometryEffect(id: "star", in: namespace)
                                }
                                
                                Text(person.name)
                                    .transition(.identity)
                                    .navTitleMatchAnimation(namespace: namespace, customTitle: person.name)
                                
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
                            PersonPreview(id: person.personId)
                                .environmentObject(environment)
                        }
                    }
                } else {
                    Text(person.name)
                        .padding(.vertical, 2)
                        .opacity(0)
                }
            }
            .buttonStyle(NavListButtonStyle())
        }
        .asAnyView()
    }
    
    func openView() -> AnyView {
        Group {
            if let focusedPerson {
                PersonView(person: focusedPerson, namespace: namespace, customMatchTitle: focusedPerson.name)
            }
        }
        .asAnyView()
    }
    
    func showNameFor(_ person: Person) -> Bool {
        viewModel.focusedId == nil || focusedPerson == person
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
    let viewModel = ScrollViewModel()
    
    return NavigationScrollView(items: .constant([
        AllPeopleNavItem(allPeople: testPeople)
    ]))
    .environmentObject(AppEnvironment())
    .environmentObject(viewModel)
}
