//
//  ContentView.swift
//  Presently
//
//  Created by Thomas Patrick on 8/1/23.
//

import SwiftUI

enum BarState {
    case open
    case closed
    case topFocus
    case bottomFocus
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
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if !navItems.isEmpty {
                    NavigationScrollView(
                        viewModel: scrollViewModel,
                        items: navItems,
                        topInset: geo.size.height / 13,
                        bottomInset: geo.size.height / 10
                    )
                    .frame(maxWidth: geo.size.width)
                    .environmentObject(scrollViewModel)
                    .transition(.opacity)
                    .accessibilityIdentifier("NavScrollView")
                }
                
                ZStack {
                    VStack(spacing: 0) {
                        TopBar(ribbonHeight: ribbonHeight(geoProxy: geo))
                            .frame(height: barHeight(geoProxy: geo, bar: .top))
                            .shiftingGlassBackground()
                            .shadow(radius: 2)
                        
                        if environment.barState != .closed {
                            Spacer()
                        }
                        
                        BottomBar(loginViewModel: loginViewModel, ribbonHeight: ribbonHeight(geoProxy: geo))
                            .frame(height: barHeight(geoProxy: geo, bar: .bottom))
                            .shiftingGlassBackground()
                            .shadow(radius: 2)
                    }
                    .zIndex(1)
                    
                    VStack {
                        if environment.barState == .topFocus {
                            Spacer()
                        }
                        
                        loginRibbon(geoProxy: geo)
                            .bounceTransition(
                                transition: .move(edge: .trailing).combined(with: .opacity),
                                animation: .barAnimation,
                                showView: .init(get: {
                                    !environment.shouldOpen
                                }, set: { _ in })) {
                                    
                                    if let currentUser = environment.currentUser,
                                       let currentExchange = environment.currentExchange,
                                       let allCurrentPeople = environment.allCurrentPeople {
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
                                        
                                        navItems = items
                                    }
                                    
                                    environment.barState = .open
                                }
                                .onAppear {
                                    ribbonHeight = ribbonHeight(geoProxy: geo)
                                }
                        
                        if environment.barState == .bottomFocus {
                            Spacer()
                        }
                    }
                    .zIndex(2)
                }
            }
        }
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
                                environment.showOnboarding = true
                                withAnimation(.bouncy) {
                                    environment.barState = .bottomFocus
                                }
                            } else if environment.currentUser != nil {
                                environment.shouldOpen = true
                            }
                        }
                    }
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
        
        switch environment.barState {
        case .open:
            return bar == .top ? viewHeight / 13 : viewHeight / 15
        case .closed:
            return viewHeight / 2
        case .topFocus:
            return bar == .top ? viewHeight : 0
        case .bottomFocus:
            return bar == .bottom ? viewHeight : 0
        }
    }
}

#Preview {
    let environment = AppEnvironment()
    let loginViewModel = LoginViewModel()
    
    return ContentView(loginViewModel: loginViewModel)
        .environmentObject(LoginStorage())
        .environmentObject(environment)
        .onAppear(perform: {
            loginViewModel.exchangeIdField = "0001"
            loginViewModel.personIdField = "0001"
        })
}
