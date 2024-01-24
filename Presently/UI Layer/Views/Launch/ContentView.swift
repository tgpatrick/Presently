//
//  ContentView.swift
//  Presently
//
//  Created by Thomas Patrick on 8/1/23.
//

import SwiftUI

enum BarState: Equatable {
    case open
    case closed
    case topFocus
    case bottomFocus(BottomBarContent)
}

enum Bar {
    case top
    case bottom
}

struct ContentView: View {
    @EnvironmentObject var environment: AppEnvironment
    
    @StateObject var scrollViewModel = ScrollViewModel()
    @StateObject var loginViewModel = LoginViewModel()
    @Namespace private var mainNamespace
    private var isLoggedIn: Bool {
        environment.currentExchange != nil && environment.currentUser != nil
    }
    
    @State private var ribbonHeight: CGFloat = 0
    @State private var navItems: [any NavItemView] = []
    
    @State private var showOnboardingAlert: Bool = false
    @StateObject private var personRepo = PersonRepository()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack {
                    if !navItems.isEmpty {
                        NavigationScrollView(
                            viewModel: scrollViewModel,
                            items: navItems,
                            topInset: geo.size.height / 13,
                            bottomInset: geo.size.height / 10
                        )
                        .frame(maxWidth: geo.size.width)
                        .environmentObject(scrollViewModel)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .accessibilityIdentifier("NavScrollView")
                    } else {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
                .safeAreaInset(edge: .top) {
                    TopBar(ribbonHeight: ribbonHeight(geoProxy: geo))
                        .frame(height: barHeight(geoProxy: geo, bar: .top))
                        .shiftingGlassBackground()
                        .shadow(radius: 2)
                }
                .safeAreaInset(edge: .bottom) {
                    BottomBar(
                        loginViewModel: loginViewModel,
                        ribbonHeight: ribbonHeight(geoProxy: geo)
                    )
                    .frame(minHeight: barHeight(geoProxy: geo, bar: .bottom))
                    .shiftingGlassBackground()
                    .shadow(radius: 2)
                }
                
                loginRibbon(geoProxy: geo)
                    .bounceTransition(
                        transition: .move(edge: .trailing).combined(with: .opacity),
                        animation: .barAnimation,
                        showView: .init(get: {
                            !environment.shouldOpen || environment.isOnboarding
                        }, set: { _ in })) {
                            environment.barState = .open
                        }
                        .onAppear {
                            ribbonHeight = ribbonHeight(geoProxy: geo)
                        }
            }
            .onChange(of: environment.currentUser) {
                if let currentUser = environment.currentUser,
                   let currentExchange = environment.currentExchange,
                   let allCurrentPeople = environment.allCurrentPeople {
                    navItems = []
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        var items: [any NavItemView] = []
                        items.append(ExchangeNavItem(userName: currentUser.name, exchange: currentExchange))
                        items.append(NextDateNavItem(exchange: currentExchange))
                        if currentExchange.started, let userAssignment = environment.userAssignment {
                            items.append(AssignedPersonNavItem(assignedPerson: userAssignment))
                            items.append(WishListNavItem(assignedPerson: userAssignment))
                        }
                        items.append(AllPeopleNavItem(allPeople: allCurrentPeople))
                        if currentExchange.id == "0001" {
                            items.append(TestNavItem())
                        }
                        
                        withAnimation {
                            navItems = items
                        }
                    }
                }
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.large)
        //TODO: Go through and set dynamicTypeSize max for different views
    }
    
    func loginRibbon(geoProxy: GeometryProxy) -> some View {
        VStack {
            Divider()
                .padding(.top)
            Spacer()
            if environment.barState == .closed {
                RibbonLoginView(loginViewModel: loginViewModel)
                    .onAppear {
                        loginViewModel.setLoginSuccess {
                            if let currentUser = environment.currentUser, !currentUser.setUp {
                                withAnimation(.bouncy) {
                                    environment.barState = .bottomFocus(.personOnboarding)
                                }
                            } else if environment.currentUser != nil {
                                environment.shouldOpen = true
                            }
                        }
                    }
            } else if environment.isOnboarding {
                Spacer()
                ZStack {
                    Text("Set up")
                        .font(.largeTitle)
                        .bold()
                    HStack {
                        Spacer()
                        Button {
                            showOnboardingAlert = true
                        } label: {
                            Image(systemName: "xmark")
                                .bold()
                        }
                        .alert("Hang on", isPresented: $showOnboardingAlert, actions: {
                            //TODO: change for exchange onboarding
                            Button("Good point, I'll stay") {}
                            Button("Remind me next time") {
                                withAnimation(.bouncy) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation(.bouncy) {
                                            environment.shouldOpen = true
                                        }
                                    }
                                }
                            }
                            Button("I'll do this later in my profile") {
                                
                                withAnimation(.bouncy) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation(.bouncy) {
                                            environment.shouldOpen = true
                                        }
                                    }
                                }
                                if var editedUser = environment.currentUser {
                                    editedUser.setUp = true
                                    Task {
                                        await personRepo.put(editedUser)
                                    }
                                }
                            }
                        }) {
                            Text("Filling out this information is what makes sure you get a gift you like and give to the right person!")
                        }
                    }
                    .padding(.trailing)
                }
                .offset(y: 15)
                .buttonStyle(DepthButtonStyle())
            }
            Spacer()
            Divider()
                .padding(.bottom)
        }
        .background {
            ZStack {
                Rectangle()
                    .foregroundStyle(Color(.accentBackground))
                    .overlay {
                        LinearGradient(
                            gradient: Gradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.clear,
                                    Color.clear
                                ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .blur(radius: 5)
                    }
                    .mask(RibbonShape())
                    .offset(CGSize(width: -1 * ribbonHeight / 1.75, height: 0))
                    .shadow(radius: 5)
                Rectangle()
                    .foregroundStyle(Color(.accentBackground))
                    .offset(CGSize(width: geoProxy.size.width - ribbonHeight / 1.75 - 10, height: 0))
                    .shadow(radius: 5, x: 10)
            }
        }
        .frame(height: ribbonHeight)
        .offset(CGSize(width: 0, height: environment.barState == .closed ? 0 : -1 * ribbonHeight / 2))
    }
    
    func ribbonHeight(geoProxy: GeometryProxy) -> CGFloat {
        return geoProxy.size.height / 6
    }
    
    func barHeight(geoProxy: GeometryProxy, bar: Bar) -> CGFloat {
        let viewHeight = geoProxy.size.height
        // Since BottomBar has a minHeight, it only needs to be told to be big when closed
        switch environment.barState {
        case .open:
            return bar == .top ? viewHeight / 13 : 0
        case .closed:
            return viewHeight / 2
        case .topFocus:
            return bar == .top ? viewHeight : 0
        case .bottomFocus:
            return 0
        }
    }
}

#Preview {
    let environment = AppEnvironment()
    let loginViewModel = LoginViewModel()
    
    return ContentView(loginViewModel: loginViewModel)
        .environmentObject(LoginStorage())
        .environmentObject(environment)
        .onAppear {
            loginViewModel.exchangeIdField = "0001"
            loginViewModel.personIdField = "0001"
        }
}
