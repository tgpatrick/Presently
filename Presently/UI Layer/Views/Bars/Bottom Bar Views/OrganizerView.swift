//
//  OrganizerView.swift
//  Presently
//
//  Created by Thomas Patrick on 11/6/23.
//

import SwiftUI

struct OrganizerView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Namespace var namespace
    @State private var blur: Double = 0
    
    @StateObject var organizerViewModel = OrganizerViewModel()
    @StateObject var exchangeRepo = ExchangeRepository()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TitledScrollView(
                title: "Organizer Tools",
                namespace: namespace,
                material: .ultraThin) {
                    if let currentExchange = environment.currentExchange, let allCurrentPeople = environment.allCurrentPeople {
                        SectionView(title: "Dates") {
                            if currentExchange.assignDate != nil {
                                DatePicker("Start Date", selection: $organizerViewModel.startDate, displayedComponents: .date)
                            } else {
                                HStack {
                                    Text("Start Date")
                                    Spacer()
                                    Button("Add") {
                                        withAnimation {
                                            environment.currentExchange?.assignDate = .now
                                            organizerViewModel.newDate = true
                                        }
                                    }
                                }
                            }
                            
                            if currentExchange.theBigDay != nil {
                                DatePicker("Gift Date", selection: $organizerViewModel.giftDate, displayedComponents: .date)
                            } else {
                                HStack {
                                    Text("Gift Date")
                                    Spacer()
                                    Button("Add") {
                                        withAnimation {
                                            environment.currentExchange?.theBigDay = .now
                                            organizerViewModel.newDate = true
                                        }
                                    }
                                }
                            }
                            
                            if organizerViewModel.startDate != currentExchange.assignDate || currentExchange.theBigDay != organizerViewModel.giftDate || organizerViewModel.newDate {
                                HStack {
                                    Spacer()
                                    Button {
                                        Task {
                                            await organizerViewModel.saveDates(exchangeRepo: exchangeRepo, environment: environment)
                                        }
                                    } label: {
                                        if exchangeRepo.isLoading {
                                            ProgressView()
                                        } else {
                                            Text("Save")
                                        }
                                    }
                                    .bold()
                                    Spacer()
                                }
                            }
                        }
                        .mainContentBox()
                        .buttonStyle(DepthButtonStyle())
                        .onAppear {
                            if let assignDate = currentExchange.assignDate {
                                organizerViewModel.startDate = assignDate
                            }
                            if let theBigDay = currentExchange.theBigDay {
                                organizerViewModel.giftDate = theBigDay
                            }
                        }
                        
                        SectionView(title: "Who is set up?") {
                            ForEach(allCurrentPeople) { person in
                                VStack {
                                    HStack {
                                        Text(person.name)
                                        Spacer()
                                        Image(systemName: person.setUp ? "checkmark.diamond.fill" : "xmark.diamond")
                                    }
                                    Divider()
                                }
                            }
                        }
                        .mainContentBox()
                    }
                }
                .blur(radius: blur)
                .padding(.horizontal)
            if let currentExchange = environment.currentExchange {
                // TODO: add actions
                if !currentExchange.started {
                    SwipeBar(
                        description: "Swipe to make assignments",
                        onChanged: adjustBlur,
                        action: {})
                        .padding(.horizontal)
                } else {
                    SwipeBar(
                        description: "Swipe to finish exchange",
                        onChanged: adjustBlur,
                        action: {})
                        .padding(.horizontal)
                }
            }
        }
    }
    
    func adjustBlur(percent: Double) {
        withAnimation {
            blur = 10 * percent
        }
    }
}

#Preview {
    let environment = AppEnvironment()
    
    return BottomBar(loginViewModel: LoginViewModel(), ribbonHeight: .zero, page: .organizer)
        .background(ShiftingBackground())
        .environmentObject(environment)
        .onAppear(perform: {
            environment.currentUser = testPerson
            environment.currentExchange = testExchange
            environment.allCurrentPeople = testPeople
            environment.barState = .bottomFocus
        })
}
