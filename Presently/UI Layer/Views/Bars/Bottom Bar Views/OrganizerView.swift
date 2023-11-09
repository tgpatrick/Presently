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
    
    @StateObject var organizerViewModel = OrganizerViewModel()
    @StateObject var exchangeRepo = ExchangeRepository()
    @StateObject var peopleRepo = PeopleRepository()
    
    @State private var blur: Double = 0
    @State private var showAssign = false
    
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
            if let currentExchange = environment.currentExchange, let currentPeople = environment.allCurrentPeople, showAssign == false {
                Group {
                    if !currentExchange.started {
                        SwipeBar(
                            description: "Swipe to make assignments",
                            onChanged: adjustBlur,
                            action: {
                                let (success, exchange, people) = organizerViewModel.assignGifts(exchange: currentExchange, people: currentPeople)
                                if success {
                                    withAnimation {
                                        showAssign = true
                                        environment.hideTabBar = true
                                    }
                                    organizerViewModel.assignUploadAndAnimate(
                                        environment: environment,
                                        assignedExchange: exchange,
                                        assignedPeople: people,
                                        exchangeRepo: exchangeRepo,
                                        peopleRepo: peopleRepo)
                                    return true
                                } else {
                                    return false
                                }
                            })
                        .matchedGeometryEffect(id: "Assignments", in: namespace)
                    } else {
                        // TODO: add action
                        SwipeBar(
                            description: "Swipe to finish exchange",
                            onChanged: adjustBlur,
                            action: { false })
                    }
                }
                .padding(.horizontal)
                .padding(.horizontal, 3)
                .padding(.bottom)
            }
            
            if showAssign {
                makingAssignmentsView
            }
        }
    }
    
    var makingAssignmentsView: some View {
        ScrollView {
            if organizerViewModel.animating {
                HStack {
                    if let animationCurrentPerson = organizerViewModel.animationCurrentPerson {
                        Text(animationCurrentPerson.name)
                            .id(animationCurrentPerson.name)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .move(edge: .bottom).combined(with: .opacity))
                            )
                        Spacer()
                    }
                    Text(organizerViewModel.animationCurrentRecipient)
                        .id(organizerViewModel.animationCurrentRecipient)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .bottom).combined(with: .opacity))
                        )
                }
                .padding()
                .frame(minHeight: 100)
                .mainContentBox()
                .padding()
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            ZStack(alignment: .topTrailing) {
                SectionView(title: "Assignments") {
                    if let allCurrentPeople = environment.allCurrentPeople {
                        ForEach(organizerViewModel.animationAssignedPeople) { person in
                            HStack {
                                Text(person.name)
                                Spacer()
                                Image(systemName: "arrow.forward")
                                Spacer()
                                Text((allCurrentPeople.getPersonById(person.recipient)?.name ?? "error"))
                            }
                            .bold()
                        }
                    }
                    if !organizerViewModel.animating {
                        HStack {
                            Spacer()
                            Button {
                                withAnimation {
                                    organizerViewModel.animationAssignedPeople = []
                                    environment.hideTabBar = false
                                    showAssign = false
                                    blur = 0
                                }
                            } label: {
                                ZStack {
                                    Text("Done")
                                        .bold()
                                        .opacity(exchangeRepo.isLoading || peopleRepo.isLoading ? 0 : 1)
                                    ProgressView()
                                        .opacity(exchangeRepo.isLoading || peopleRepo.isLoading ? 1 : 0)
                                }
                            }
                            Spacer()
                        }
                        .buttonStyle(DepthButtonStyle())
                    }
                }
                if !organizerViewModel.animating {
                    ShareLink(item: organizerViewModel.getShareString()) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .padding(.horizontal)
                }
            }
            .fillHorizontally()
            .mainContentBox()
            .transition(.move(edge: .top).combined(with: .opacity))
            .padding()
        }
        .fillHorizontally()
        .matchedGeometryEffect(id: "Assignments", in: namespace)
        .scrollDisabled(organizerViewModel.animating)
    }
    
    func adjustBlur(percent: Double) {
        withAnimation {
            blur = 20 * percent
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
