//
//  OnboardPeopleView.swift
//  Presently
//
//  Created by Thomas Patrick on 1/29/24.
//

import SwiftUI

struct OnboardPeopleView: View {
    @EnvironmentObject var onboardingViewModel: ExchangeOnboardingViewModel
    var canProceed: Bool {
        onboardingViewModel.organizer != nil && !onboardingViewModel.people.isEmpty
    }
    let index: Int
    
    enum PeopleField: Hashable {
        case organizer
        case person
    }
    
    @FocusState var focusState: PeopleField?
    @Namespace var namespace
    @State var showOrganizerField = false
    @State var organizerField = ""
    
    @State var showPersonField = false
    @State var personField = ""
    
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Text("Last, let's add some people!")
                    .font(.title)
                    .bold()
            }
            .multilineTextAlignment(.center)
            .padding()
            
            VStack(alignment: .leading) {
                if focusState != .person {
                    Text("The organizer (you)")
                        .font(.title3)
                        .bold()
                    HStack {
                        if onboardingViewModel.organizer == nil {
                            if !showOrganizerField {
                                Spacer()
                                Button {
                                    withAnimation {
                                        showOrganizerField = true
                                        focusState = .organizer
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                        .bold()
                                }
                                .matchedGeometryEffect(id: "organizerButton", in: namespace)
                                Spacer()
                            } else {
                                TextField("Name", text: $organizerField)
                                    .padding(.trailing)
                                    .focused($focusState, equals: .organizer)
                                Button {
                                    withAnimation {
                                        onboardingViewModel.organizer = onboardingViewModel.generatePerson(name: organizerField, isOrganizer: true)
                                    }
                                } label: {
                                    Image(systemName: "checkmark")
                                        .bold()
                                }
                            }
                        } else {
                            Text(onboardingViewModel.organizer?.name ?? "")
                                .bold()
                            Spacer()
                        }
                        if onboardingViewModel.organizer != nil || showOrganizerField {
                            Button {
                                withAnimation {
                                    onboardingViewModel.organizer = nil
                                    showOrganizerField = false
                                    organizerField = ""
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .bold()
                            }
                            .matchedGeometryEffect(id: "organizerButton", in: namespace)
                        }
                    }
                    .mainContentBox()
                    .padding(.horizontal)
                }
                
                if focusState != .organizer {
                    Text("Everyone else")
                        .font(.title3)
                        .bold()
                    ScrollView {
                        VStack {
                            if focusState != .person {
                                ForEach(onboardingViewModel.people) { person in
                                    VStack {
                                        HStack {
                                            Text(person.name)
                                            Spacer()
                                            Button {
                                                withAnimation {
                                                    onboardingViewModel.people.removeAll(where: { $0 == person })
                                                }
                                            } label: {
                                                Image(systemName: "xmark")
                                                    .bold()
                                            }
                                        }
                                        Divider()
                                    }
                                }
                            }
                            if !showPersonField {
                                Button {
                                    withAnimation {
                                        showPersonField = true
                                        focusState = .person
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                        .bold()
                                }
                            } else {
                                HStack {
                                    TextField("Name", text: $personField)
                                        .padding(.trailing)
                                        .focused($focusState, equals: .person)
                                    Button {
                                        withAnimation {
                                            onboardingViewModel.people.append( onboardingViewModel.generatePerson(name: personField, isOrganizer: false)
                                            )
                                            showPersonField = false
                                            personField = ""
                                        }
                                    } label: {
                                        Image(systemName: "checkmark")
                                            .bold()
                                    }
                                    
                                    Button {
                                        withAnimation {
                                            showPersonField = false
                                            personField = ""
                                        }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .bold()
                                    }
                                }
                            }
                        }
                        .fillHorizontally()
                        .mainContentBox()
                        .padding(.horizontal)
                    }
                }
            }
            .buttonStyle(DepthButtonStyle(padding: 1))
            .textFieldStyle(InsetTextFieldStyle(alignment: .leading))
            Spacer()
        }
        .onChange(of: onboardingViewModel.scrollPosition) { _, newValue in
            if newValue == index && !canProceed {
                onboardingViewModel.canProceedTo = index
            }
        }
        .onChange(of: canProceed) { _, newValue in
            if newValue {
                withAnimation {
                    onboardingViewModel.canProceedTo = index + 1
                }
            } else if onboardingViewModel.canProceedTo <= index {
                withAnimation {
                    onboardingViewModel.canProceedTo = index
                }
            }
        }
        .onChange(of: focusState) { _, newValue in
            onboardingViewModel.hideButtons = newValue != nil
        }
    }
}

#Preview {
    let environment = AppEnvironment()
    let viewModel = ExchangeOnboardingViewModel()
    
    return OnboardingView<ExchangeOnboardingViewModel, ExchangeRepository>(
        items: [
            Text("First View").asAnyView(),
            OnboardPeopleView(index: 1).asAnyView()
        ],
        onClose: {})
    .background { ShiftingBackground().ignoresSafeArea() }
    .environmentObject(viewModel)
    .environmentObject(environment)
    .onAppear {
        viewModel.scrollPosition = 1
    }
}
