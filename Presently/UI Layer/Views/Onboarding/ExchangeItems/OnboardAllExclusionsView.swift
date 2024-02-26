//
//  OnboardAllExclusionsView.swift
//  Presently
//
//  Created by Thomas Patrick on 2/24/24.
//

import SwiftUI

struct OnboardAllExclusionsView: View {
    @EnvironmentObject var onboardingViewModel: ExchangeOnboardingViewModel
    let index: Int
    
    @FocusState private var focusState
    private var allPeople: People {
        if let organizer = onboardingViewModel.organizer {
            return onboardingViewModel.people + [organizer]
        } else {
            return onboardingViewModel.people
        }
    }
    
    @State private var giverID: String = "-1"
    var giver: Person? {
        allPeople.getPersonById(giverID)
    }
    @State private var recipientID: String = "-1"
    var recipient: Person? {
        allPeople.getPersonById(recipientID)
    }
    
    @State private var showSaveSuccessIcon = false
    @State private var showSaveFailIcon = false
    
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Text("Finally, add any exclusions")
                    .font(.title)
                    .bold()
                Text("If there's anyone who can't give to anyone else (siblings, spouses, coworkers), add that here. Then you're done!")
            }
            .multilineTextAlignment(.center)
            .padding(.vertical)
            
            ScrollView {
                VStack {
                    VStack {
                        Picker("", selection: $giverID) {
                            if giverID == "-1" {
                                Text("Select").tag("-1")
                            }
                            ForEach(allPeople.sorted()) { person in
                                if person.personId != recipientID {
                                    Text(person.name).tag(person.personId)
                                }
                            }
                        }
                        
                        Text("Can't give to")
                        
                        Picker("", selection: $recipientID) {
                            if recipientID == "-1" {
                                Text("Select").tag("-1")
                            }
                            ForEach(allPeople.sorted()) { person in
                                if person.personId != giverID {
                                    Text(person.name).tag(person.personId)
                                }
                            }
                        }
                        
                        ZStack {
                            Button("Save") {
                                withAnimation {
                                    if giverID != "-1" && recipientID != "-1" && giverID != recipientID {
                                        if let organizer = onboardingViewModel.organizer, giverID == organizer.personId, !organizer.exceptions.contains(recipientID) {
                                            onboardingViewModel.organizer?.exceptions.append(recipientID)
                                        } else if let giverIndex = onboardingViewModel.people.firstIndex(where: { $0.personId == giverID }), !onboardingViewModel.people[giverIndex].exceptions.contains(recipientID) {
                                            onboardingViewModel.people[giverIndex].exceptions.append(recipientID)
                                        }
                                        showSaveSuccess()
                                    } else {
                                        showSaveFail()
                                    }
                                }
                            }
                            .buttonStyle(DepthButtonStyle())
                            
                            HStack {
                                Spacer()
                                if showSaveSuccessIcon {
                                    Spacer()
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 25)
                                        .foregroundStyle(.green)
                                    Spacer()
                                }
                                if showSaveFailIcon {
                                    Spacer()
                                    Spacer()
                                    Image(systemName: "xmark.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 25)
                                        .foregroundStyle(.red)
                                    Spacer()
                                }
                            }
                            .transition(.opacity)
                        }
                        .fillHorizontally()
                    }
                    .mainContentBox()
                    .padding()
                    
                    VStack {
                        ForEach(allPeople.sorted()) { person in
                            VStack {
                                HStack {
                                    Text(person.name)
                                        .font(.title2)
                                        .bold()
                                    Spacer()
                                }
                                if !person.exceptions.isEmpty {
                                    VStack {
                                        ForEach(person.exceptions, id: \.self) { exclusionID in
                                            if let excludedPerson = allPeople.getPersonById(exclusionID) {
                                                VStack {
                                                    HStack {
                                                        Text(excludedPerson.name)
                                                        
                                                        Spacer()
                                                        
                                                        Button {
                                                            withAnimation {
                                                                if person == onboardingViewModel.organizer {
                                                                    onboardingViewModel.organizer?.exceptions.removeAll(where: { $0 == excludedPerson.personId })
                                                                } else {
                                                                    if let personIndex = onboardingViewModel.people.firstIndex(where: { $0.personId == person.personId }) {
                                                                        onboardingViewModel.people[personIndex].exceptions.removeAll(where: { $0 == exclusionID })
                                                                    }
                                                                }
                                                            }
                                                        } label: {
                                                            Image(systemName: "xmark")
                                                                .bold()
                                                        }
                                                        .buttonStyle(DepthButtonStyle(shape: Circle(), shadowRadius: 3, padding: 2))
                                                    }
                                                    .padding(.horizontal)
                                                    Divider()
                                                }
                                            } else {
                                                Text(exclusionID)
                                            }
                                        }
                                    }
                                } else {
                                    Text("(none)")
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            
            Spacer()
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .onChange(of: onboardingViewModel.scrollPosition) { _, newValue in
            if newValue == index {
                onboardingViewModel.canProceedTo = index + 1
            }
        }
    }
    
    func showSaveSuccess() {
        withAnimation {
            showSaveSuccessIcon = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showSaveSuccessIcon = false
            }
        }
    }
    
    
    func showSaveFail() {
        withAnimation {
            showSaveFailIcon = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showSaveFailIcon = false
            }
        }
    }
}

#Preview {
    let environment = AppEnvironment()
    let viewModel = ExchangeOnboardingViewModel()
    
    return OnboardingView<ExchangeOnboardingViewModel, ExchangeRepository>(
        items: [
            Text("Second View").asAnyView(),
            OnboardAllExclusionsView(index: 1).asAnyView()
        ],
        onClose: {})
    .background { ShiftingBackground().ignoresSafeArea() }
    .environmentObject(viewModel)
    .environmentObject(environment)
    .onAppear {
        testPeople.removeAll(where: { $0.personId == "0001" })
        viewModel.people = testPeople
        viewModel.organizer = testPerson
        viewModel.scrollPosition = 1
    }
}
