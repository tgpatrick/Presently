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
    @State private var barHeight: CGFloat = 50
    
    var body: some View {
        VStack {
            if !isLoggedIn {
                BottomLoginView(loginViewModel: loginViewModel)
                    .padding(.top, ribbonHeight / 2)
            } else {
                switch environment.barState {
                case .open, .bottomFocus:
                    if !environment.showOnboarding {
                        tabView
                    } else if environment.barState == .bottomFocus {
                        OnboardingView(
                            items: [
                                OnboardWelcomePersonView().asAnyView(),
                                OnboardGreetingView().asAnyView(),
                                OnboardWishListView().asAnyView(),
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
                    EmptyView()
                }
            }
        }
        .fillHorizontally()
    }
    
    var tabView: some View {
        VStack(spacing: 0) {
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
                                        .padding()
                                }
                        case .organizer:
                            OrganizerView(
                                namespace: _bottomNamespace
                            )
                        case .home:
                            EmptyView()
                        }
                    }
                    .padding(.top)
                    
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
            }
            
            Spacer()
            if !environment.hideTabBar {
                bottomTabBar
                    .transition(.opacity)
            }
        }
    }
    
    //TODO: Show icons on iPhone SE
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
                        .resizable()
                        .fontWeight(.light)
                        .aspectRatio(contentMode: .fit)
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
                        .resizable()
                        .fontWeight(.light)
                        .aspectRatio(contentMode: .fit)
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
                            .resizable()
                            .fontWeight(.light)
                            .aspectRatio(contentMode: .fit)
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
        .padding(.bottom, 25)
        .padding(.top, 15)
        .ignoresSafeArea(.container, edges: .bottom)
        .background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    barHeight = geo.size.height
                }
            }
        )
        .frame(height: barHeight)
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
