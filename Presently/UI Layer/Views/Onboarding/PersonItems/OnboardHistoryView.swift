//
//  OnboardHistoryView.swift
//  Presently
//
//  Created by Thomas Patrick on 11/3/23.
//

import SwiftUI

struct OnboardHistoryView: View {
    @EnvironmentObject var environment: AppEnvironment
    @EnvironmentObject var onboardingViewModel: PersonOnboardingViewModel
    
    private let thisYear: Int = Calendar.current.component(.year, from: .now)
    @State private var year = Calendar.current.component(.year, from: Calendar.current.date(byAdding: .year, value: -1, to: .now) ?? .now)
    @State private var recipientId = ""
    @State private var showEdit = false
    
    var body: some View {
        VStack {
            Text("Gift History")
                .font(.title)
                .bold()
            Text("Tell us who you've given to in this group (even before Presently!) so that the algorithm can make the best assignments.")
                .multilineTextAlignment(.center)
                .padding()
            VStack {
                Spacer()
                if !onboardingViewModel.giftHistory.isEmpty && !showEdit {
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(onboardingViewModel.giftHistory, id: \.self) { gift in
                                if let person = environment.getPerson(id: gift.recipientId) {
                                    HStack {
                                        Text("In \(String(gift.year)), you gave to \(person.name)")
                                        Spacer()
                                        Button("Delete") {
                                            withAnimation {
                                                onboardingViewModel.giftHistory.removeAll(where: { $0 == gift })
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
                            Text("In")
                            Picker("Select a year", selection: $year) {
                                ForEach(2000..<thisYear, id: \.self) { year in
                                    Text("\(String(year))").tag(year)
                                }
                            }
                        }
                        HStack {
                            Text("I gave to")
                            Picker("Select a name", selection: $recipientId) {
                                ForEach(environment.allCurrentPeople ?? []) { person in
                                    if person != environment.currentUser {
                                        Text(person.name).tag(person.personId)
                                    }
                                }
                            }
                        }
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
                                onboardingViewModel.giftHistory.append(
                                    HistoricalGift(
                                        year: year,
                                        recipientId: recipientId,
                                        description: "")
                                )
                                onboardingViewModel.giftHistory.sort { lhs, rhs in
                                    lhs > rhs
                                }
                                withAnimation {
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
                    Text("(no record yet)")
                }
                Spacer()
            }
            .fillHorizontally()
            .mainContentBox(material: .ultraThin, padding: 0)
            .padding()
            Spacer()
            Button("Add a gift") {
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
        .onAppear {
            recipientId = environment.allCurrentPeople?.first?.personId ?? ""
        }
    }
}

#Preview {
    let environment = AppEnvironment()
    return OnboardingView<PersonOnboardingViewModel, PersonRepository>(
        items: [
            OnboardHistoryView().asAnyView(),
            OnboardWishListView().asAnyView()
        ],
        onClose: {})
    .background { ShiftingBackground().ignoresSafeArea() }
    .environmentObject(environment)
    .environmentObject(PersonOnboardingViewModel())
    .onAppear {
        environment.allCurrentPeople = testPeople
    }
}
