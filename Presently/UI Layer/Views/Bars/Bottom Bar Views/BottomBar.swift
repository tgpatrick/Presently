//
//  BottomBar.swift
//  Presently
//
//  Created by Thomas Patrick on 9/28/23.
//

import SwiftUI

enum BottomBarContent {
    case exchangeOnboarding
    case personOnboarding
    case profile
    case tools
}

struct BottomBar: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Namespace private var bottomNamespace
    private var isLoggedIn: Bool {
        environment.currentExchange != nil && environment.currentUser != nil
    }
    
    @StateObject var personOnboardingViewModel = PersonOnboardingViewModel()
    @StateObject var exchangeOnboardingViewModel = ExchangeOnboardingViewModel()
    @ObservedObject var loginViewModel: LoginViewModel
    @State var ribbonHeight: CGFloat
    
    var body: some View {
        HStack {
            if !isLoggedIn {
                if environment.barState == .bottomFocus(.exchangeOnboarding) {
                    OnboardingView<ExchangeOnboardingViewModel, ExchangeRepository>(
                        items: [
                            OnboardWelcomeExchangeView(index: 0).asAnyView(),
                            OnboardExchangeNameView(index: 1).asAnyView(),
                            OnboardDatesView(index: 2).asAnyView(),
                            OnboardExchangeSettingsView(index: 3).asAnyView(),
                            OnboardIntroAndRulesView(index: 4).asAnyView(),
                            OnboardPeopleView(index: 5).asAnyView(),
                            OnboardAllExclusionsView(index: 6).asAnyView()
                        ],
                        onClose: {
                            withAnimation(.bouncy) {
                                environment.shouldOpen = true
                            }
                        }
                    )
                    .padding(.top, ribbonHeight / 3)
                    .environmentObject(exchangeOnboardingViewModel)
                    .onAppear {
                        exchangeOnboardingViewModel.reset()
                    }
                } else {
                    Spacer()
                    BottomLoginView(loginViewModel: loginViewModel)
                        .padding(.top, ribbonHeight / 2)
                    Spacer()
                }
            } else {
                switch environment.barState {
                case .open, .bottomFocus(_):
                    if environment.barState == .bottomFocus(.personOnboarding) {
                        OnboardingView<PersonOnboardingViewModel, PersonRepository>(
                            items: [
                                OnboardWelcomePersonView().asAnyView(),
                                OnboardExchangeView().asAnyView(),
                                OnboardGreetingView().asAnyView(),
                                OnboardWishListView().asAnyView(),
                                OnboardExclusionsView().asAnyView(),
                                OnboardHistoryView().asAnyView(),
                                OnboardFinishPersonView().asAnyView()
                            ],
                            onClose: {
                                withAnimation(.bouncy) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation(.bouncy) {
                                            environment.shouldOpen = true
                                        }
                                    }
                                }
                            }
                        )
                        .padding(.top, ribbonHeight / 2)
                        .environmentObject(personOnboardingViewModel)
                    } else {
                        tabView
                    }
                default:
                    Spacer()
                }
            }
        }
    }
    
    var tabView: some View {
        HStack {
            switch environment.barState {
            case .bottomFocus(let page):
                ZStack(alignment: .top) {
                    Group {
                        switch page {
                        case .profile:
                            TitledScrollView(
                                title: "Profile",
                                namespace: bottomNamespace,
                                material: .ultraThin) {
                                    ProfileView()
                                        .safeAreaPadding()
                                }
                        case .tools:
                            OrganizerView(
                                namespace: _bottomNamespace
                            )
                        default:
                            EmptyView()
                        }
                    }
                    .safeAreaPadding(.top)
                    
                    HStack {
                        Spacer()
                        if !environment.hideTabBar {
                            Button {
                                withAnimation(.spring()) {
                                    environment.barState = .open
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .bold()
                            }
                            .buttonStyle(DepthButtonStyle(shape: Circle()))
                        }
                    }
                    .padding()
                }
            default:
                Spacer()
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !environment.hideTabBar {
                bottomTabBar
                    .transition(.move(edge: .bottom))
            }
        }
    }
    
    var bottomTabBar: some View {
        var state: BarState {
            return environment.barState
        }
        
        return HStack {
            Spacer()
            Button {
                withAnimation(.spring()) {
                    environment.barState = .open
                }
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: state == .open ? "house.fill" : "house")
                        .tabBarImage()
                    Text("Home")
                        .fontWeight(.black)
                }
            }
            Spacer()
            Button {
                withAnimation(.spring()) {
                    environment.barState = .bottomFocus(.profile)
                }
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: state == .bottomFocus(.profile) ? "person.fill" : "person")
                        .tabBarImage()
                    Text("Profile")
                        .fontWeight(.black)
                }
            }
            Spacer()
            if let currentUser = environment.currentUser, currentUser.organizer {
                Button {
                    withAnimation(.spring()) {
                        environment.barState = .bottomFocus(.tools)
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: state == .bottomFocus(.tools) ? "wrench.and.screwdriver.fill" : "wrench.and.screwdriver")
                            .tabBarImage()
                        Text("Tools")
                            .fontWeight(.black)
                    }
                }
                Spacer()
            }
        }
        .font(.caption)
        .shadow(radius: 1)
        .shadow(radius: 1)
        .foregroundStyle(Color(.accentLight))
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .background {
            switch environment.barState {
            case .bottomFocus(_):
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .padding(.top, -10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .ignoresSafeArea(edges: .bottom)
            default:
                Color.clear
            }
        }
    }
}

#Preview {
    let environment = AppEnvironment()
    let loginViewModel = LoginViewModel()
    
    return BottomBar(loginViewModel: loginViewModel, ribbonHeight: .zero)
        .background(ShiftingBackground())
        .environmentObject(environment)
        .onAppear(perform: {
            environment.currentUser = testPerson
            environment.currentExchange = testExchange
            environment.allCurrentPeople = testPeople
            environment.barState = .bottomFocus(.profile)
        })
}
