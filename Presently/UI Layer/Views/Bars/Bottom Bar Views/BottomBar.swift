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
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var environment: AppEnvironment
    @Namespace private var botttomNamespace
    private var isLoggedIn: Bool {
        environment.currentExchange != nil && environment.currentUser != nil
    }
    
    @ObservedObject var loginViewModel: LoginViewModel
    @State var ribbonHeight: CGFloat
    @State private var page: BottomBarPage = .home
    @State private var barHeight: CGFloat = 50
    
    var body: some View {
        HStack {
            switch environment.barState {
            case .closed:
                if !isLoggedIn {
                    BottomLoginView(loginViewModel: loginViewModel)
                        .padding(.top, ribbonHeight / 2)
                }
            case .topFocus:
                EmptyView()
            case .open, .bottomFocus:
                VStack {
                    if isLoggedIn {
                        if environment.barState == .bottomFocus {
                            VStack {
                                ZStack(alignment: .top) {
                                    Group {
                                        switch page {
                                        case .profile:
                                            TitledScrollView(
                                                title: "Profile",
                                                namespace: botttomNamespace) {
                                                    ProfileView()
                                                }
                                        case .organizer:
                                            TitledScrollView(
                                                title: "Organizer Tools",
                                                namespace: botttomNamespace) {
                                                    VStack(spacing: 15) {
                                                        Text("This is the organizer tool page, I guess")
                                                            .fillHorizontally()
                                                            .padding()
                                                            .background(.ultraThinMaterial)
                                                            .cornerRadius(15)
                                                        Text("This a second piece of it, I guess")
                                                            .fillHorizontally()
                                                            .padding()
                                                            .background(.ultraThinMaterial)
                                                            .cornerRadius(15)
                                                    }
                                                    .padding()
                                                }
                                        case .home:
                                            EmptyView()
                                        }
                                    }
                                    .padding(.top)
                                    
                                    HStack {
                                        Spacer()
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
                                    .padding()
                                }
                            }
                        }
                        Spacer()
                        bottomTabBar
                    }
                }
            }
        }
        .fillHorizontally()
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
                        .resizable()
                        .fontWeight(.light)
                        .aspectRatio(contentMode: .fit)
                    Text("Home")
                        .bold()
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
                        .bold()
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
                            .bold()
                    }
                }
                Spacer()
            }
        }
        .font(.caption)
        .shadow(radius: 1)
        .shadow(radius: 1)
        .foregroundStyle(colorScheme == .light ? Color(.accentBackground) : Color(.accent))
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
    var environment = AppEnvironment()
    var loginViewModel = LoginViewModel()
    
    return ContentView(loginViewModel: loginViewModel)
        .environmentObject(LoginStorage())
        .environmentObject(environment)
        .onAppear(perform: {
            loginViewModel.exchangeIdField = "0001"
            loginViewModel.personIdField = "0001"
        })
}
