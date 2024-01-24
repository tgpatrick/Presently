//
//  BottomBar.swift
//  Presently
//
//  Created by Thomas Patrick on 9/28/23.
//

import SwiftUI

enum BottomBarPage {
    case home
    case profile
    case organizer
}

struct BottomBar: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Namespace private var bottomNamespace
    private var isLoggedIn: Bool {
        environment.currentExchange != nil && environment.currentUser != nil
    }
    
    @StateObject var personOnboardingViewModel = PersonOnboardingViewModel()
    @ObservedObject var loginViewModel: LoginViewModel
    @State var ribbonHeight: CGFloat
    @State var page: BottomBarPage = .home
    
    var body: some View {
        HStack {
            if !isLoggedIn {
                Spacer()
                BottomLoginView(loginViewModel: loginViewModel)
                    .padding(.top, ribbonHeight / 2)
                Spacer()
            } else {
                switch environment.barState {
                case .open, .bottomFocus:
                    if !environment.showOnboarding {
                        tabView
                    } else if environment.barState == .bottomFocus {
                        OnboardingView(
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
                                    environment.showOnboarding = false
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
                    }
                default:
                    Spacer()
                }
            }
        }
    }
    
    var tabView: some View {
        HStack {
            if environment.barState == .bottomFocus {
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
                        case .organizer:
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
                                    page = .home
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
            } else {
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
        HStack {
            Spacer()
            Button {
                withAnimation(.spring()) {
                    page = .home
                    environment.barState = .open
                }
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: page == .home ? "house.fill" : "house")
                        .tabBarImage()
                    Text("Home")
                        .fontWeight(.black)
                }
            }
            Spacer()
            Button {
                withAnimation(.spring()) {
                    page = .profile
                    environment.barState = .bottomFocus
                }
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: page == .profile ? "person.fill" : "person")
                        .tabBarImage()
                    Text("Profile")
                        .fontWeight(.black)
                }
            }
            Spacer()
            if let currentUser = environment.currentUser, currentUser.organizer {
                Button {
                    withAnimation(.spring()) {
                        page = .organizer
                        environment.barState = .bottomFocus
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: page == .organizer ? "wrench.and.screwdriver.fill" : "wrench.and.screwdriver")
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
            if environment.barState == .bottomFocus {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .padding(.top, -10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .id("TabBar")
    }
}

#Preview {
    let environment = AppEnvironment()
    let loginViewModel = LoginViewModel()
    
    return BottomBar(loginViewModel: loginViewModel, ribbonHeight: .zero, page: .profile)
        .background(ShiftingBackground())
        .environmentObject(environment)
        .onAppear(perform: {
            environment.currentUser = testPerson
            environment.currentExchange = testExchange
            environment.allCurrentPeople = testPeople
            environment.barState = .bottomFocus
        })
}
