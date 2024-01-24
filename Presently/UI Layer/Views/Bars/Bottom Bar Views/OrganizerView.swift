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
    @State private var showAssignAnimation = false
    @State private var showRestartAnimation = false
    @State private var showDeleteAnimation = false
    @State private var copiedId: String?
    private var showingAnimation: Bool {
        return showAssignAnimation || showRestartAnimation || showDeleteAnimation
    }
    
    var body: some View {
        ZStack {
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
                        
                        if currentExchange.started && !organizerViewModel.animating {
                            ZStack(alignment: .topTrailing) {
                                SectionView(title: "Assignments") {
                                    ForEach(allCurrentPeople.sorted()) { person in
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
                                ShareLink(item: organizerViewModel.getShareString(from: allCurrentPeople)) {
                                    Image(systemName: "square.and.arrow.up")
                                }
                                .padding(.horizontal)
                            }
                            .fillHorizontally()
                            .mainContentBox()
                        }
                        
                        SectionView(title: "Who is set up?") {
                            ForEach(allCurrentPeople.sorted()) { person in
                                VStack {
                                    HStack {
                                        Image(systemName: person.setUp ? "checkmark.diamond.fill" : "xmark.diamond")
                                            .bold()
                                        Text(person.name)
                                        Spacer()
                                        
                                        Text(person.exchangeId + "-" + person.personId)
                                            .font(.caption)
                                        Button {
                                            let invite = "Your Presently code is \(person.id)"
                                            let pasteboard = UIPasteboard.general
                                            pasteboard.string = invite
                                            if let string = pasteboard.string, string == invite {
                                                copiedId = person.personId
                                            }
                                        } label: {
                                            Image(systemName: copiedId == person.personId ? "checkmark" : "doc.on.doc")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 15, height: 15)
                                                .fontWeight(.heavy)
                                        }
                                    }
                                    Divider()
                                }
                            }
                        }
                        .mainContentBox()
                        .buttonStyle(DepthButtonStyle(shadowRadius: 2, padding: 1))
                        .symbolTransitionIfAvailable()
                        
                        SectionView(title: "Exclusions") {
                            ForEach(allCurrentPeople.sorted()) { person in
                                VStack(alignment: .leading) {
                                    Text(person.name)
                                        .bold()
                                    VStack(alignment: .leading) {
                                        if !person.exceptions.isEmpty {
                                            ForEach(person.exceptions, id: \.self) { exclusion in
                                                Text(allCurrentPeople.getPersonById(exclusion)?.name ?? "error")
                                            }
                                        } else {
                                            Text("(none)")
                                        }
                                    }
                                    .padding(.leading)
                                }
                            }
                        }
                        .mainContentBox()
                    }
                }
                .blur(radius: blur)
                .safeAreaPadding(.horizontal)
                .refreshable {
                    await environment.refreshFromServer(exchangeRepo: exchangeRepo, peopleRepo: peopleRepo)
                }
                .safeAreaInset(edge: .bottom) {
                    if let currentExchange = environment.currentExchange, let currentPeople = environment.allCurrentPeople, !showingAnimation {
                        Group {
                            // TODO: Make swipe bar only show when appropriate dates are near
                            if !currentExchange.started {
                                SwipeBar(
                                    description: "Slide to make assignments",
                                    onChanged: adjustBlur,
                                    action: {
                                        let (success, exchange, people) = organizerViewModel.assignGifts(exchange: currentExchange, people: currentPeople)
                                        if success {
                                            withAnimation {
                                                showAssignAnimation = true
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
                                .matchedGeometryEffect(id: "AssignmentsAnimation", in: namespace)
                            } else {
                                SwipeBar(
                                    description: "Slide after gifting",
                                    onChanged: adjustBlur,
                                    action: {
                                        if let exchange = environment.currentExchange,
                                           let people = environment.allCurrentPeople,
                                           let (endedExchange, peopleWithHistory) =
                                            organizerViewModel.endExchange(
                                                exchange: exchange,
                                                people: people) {
                                            
                                            withAnimation {
                                                showRestartAnimation = true
                                                environment.hideTabBar = true
                                            }
                                            
                                            organizerViewModel.endUploadAndAnimate(
                                                environment: environment,
                                                exchange: endedExchange,
                                                people: peopleWithHistory,
                                                exchangeRepo: exchangeRepo,
                                                peopleRepo: peopleRepo)
                                            return true
                                        } else {
                                            return false
                                        }
                                    })
                            }
                        }
                        .padding(.horizontal)
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            
            if showAssignAnimation {
                makingAssignmentsView
            }
            if showRestartAnimation {
                restartingExchangeView
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
                            .transition(.move(edge: .top))
                        }
                    }
                    if !organizerViewModel.animating {
                        HStack {
                            Spacer()
                            Button {
                                withAnimation {
                                    organizerViewModel.animationAssignedPeople = []
                                    environment.hideTabBar = false
                                    showAssignAnimation = false
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
        .matchedGeometryEffect(id: "AssignmentsAnimation", in: namespace)
        .scrollDisabled(organizerViewModel.animating)
    }
    
    var restartingExchangeView: some View {
        VStack {
            if let animationCurrentPerson = organizerViewModel.animationCurrentPerson {
                Text(animationCurrentPerson.name)
                    .id(animationCurrentPerson.name)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity))
                    )
                Spacer()
            }
            Text("gave to")
            Spacer()
            Text(organizerViewModel.animationCurrentRecipient)
                .id(organizerViewModel.animationCurrentRecipient)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity))
                )
        }
        .padding()
        .frame(maxHeight: 150)
        .mainContentBox()
        .padding()
        .transition(.move(edge: .top).combined(with: .opacity))
        .onChange(of: organizerViewModel.animating) { newValue in
            if !newValue {
                withAnimation {
                    environment.hideTabBar = false
                    showRestartAnimation = newValue
                    blur = 0
                }
            }
        }
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
