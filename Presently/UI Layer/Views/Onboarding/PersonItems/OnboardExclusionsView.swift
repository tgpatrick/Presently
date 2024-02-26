//
//  OnboardExceptionsView.swift
//  Presently
//
//  Created by Thomas Patrick on 11/12/23.
//

import SwiftUI

struct OnboardExclusionsView: View {
    @EnvironmentObject var environment: AppEnvironment
    @EnvironmentObject var onboardingViewModel: PersonOnboardingViewModel
    
    @State private var exclusionId = ""
    @State private var showEdit = false
    
    var body: some View {
        VStack {
            Text("Exclusions")
                .font(.title)
                .bold()
            Text("Is there anyone you can't give to in this group? Depending on the rules, this may be a significant other, family member, close work colleague, etc.")
                .multilineTextAlignment(.center)
                .padding()
            VStack {
                Spacer()
                if !onboardingViewModel.exclusions.isEmpty && !showEdit {
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(onboardingViewModel.exclusions, id: \.self) { exclusion in
                                if let person = environment.getPerson(id: exclusion) {
                                    HStack {
                                        Text(person.name)
                                        Spacer()
                                        Button("Delete") {
                                            withAnimation {
                                                onboardingViewModel.exclusions.removeAll(where: { $0 == exclusion })
                                            }
                                        }
                                        .buttonStyle(DepthButtonStyle(backgroundColor: .red))
                                    }
                                    .padding()
                                    Divider()
                                }
                            }
                        }
                    }
                } else if showEdit {
                    VStack(spacing: 0) {
                        HStack {
                            Text("I can't give to")
                            Picker("Select a name", selection: $exclusionId) {
                                ForEach(environment.allCurrentPeople ?? []) { person in
                                    if person != environment.currentUser {
                                        Text(person.name).tag(person.personId)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        HStack {
                            Spacer()
                            Button("Cancel") {
                                withAnimation {
                                    showEdit = false
                                }
                            }
                            .buttonStyle(DepthButtonStyle(backgroundColor: .red))
                            Spacer()
                            Button("Save") {
                                withAnimation {
                                    if exclusionId != "" {
                                        onboardingViewModel.exclusions.append(exclusionId)
                                    }
                                    showEdit = false
                                }
                            }
                            .buttonStyle(DepthButtonStyle(backgroundColor: .green))
                            Spacer()
                        }
                        .padding(.vertical)
                        .foregroundStyle(Color.black)
                    }
                } else {
                    Text("(no exclusions)")
                }
                Spacer()
            }
            .fillHorizontally()
            .mainContentBox(material: .ultraThin, padding: 0)
            .padding()
            Spacer()
            Button("Add") {
                withAnimation {
                    showEdit = true
                }
            }
            .buttonStyle(DepthButtonStyle())
            .padding(.vertical)
            .padding(.bottom, 5)
            .disabled(showEdit)
            .opacity(showEdit ? 0 : 1)
        }
    }
}

#Preview {
    let environment = AppEnvironment()
    return OnboardingView<PersonOnboardingViewModel, PersonRepository>(
        items: [
            OnboardExclusionsView().asAnyView(),
            OnboardHistoryView().asAnyView()
        ],
        onClose: {})
    .background { ShiftingBackground().ignoresSafeArea() }
    .environmentObject(environment)
    .environmentObject(PersonOnboardingViewModel())
    .onAppear {
        environment.allCurrentPeople = testPeople
    }
}
