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
    @State private var barState: BarState = .closed
    @State private var shouldOpen: Bool = false
    @StateObject private var scrollViewModel = ScrollViewModel()
    @StateObject private var loginViewModel = LoginViewModel()
    @Namespace private var mainNamespace
    private var isLoggedIn: Bool {
        environment.currentExchange != nil && environment.currentUser != nil
    }
    @State private var ribbonHeight: CGFloat = 0
    @State private var navItems: [any NavItemView] = []
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if navItems.count > 0 {
                    NavigationScrollView(
                        viewModel: scrollViewModel,
                        items: navItems,
                        topInset: geo.size.height / 13,
                        bottomInset: geo.size.height / 10
                    )
                    .frame(maxWidth: geo.size.width)
                    .environmentObject(scrollViewModel)
                    .transition(.opacity)
                }
                
                ZStack {
                    VStack(spacing: 0) {
                        topBar(geoProxy: geo)
                        
                        if barState != .closed {
                            Spacer()
                        }
                        
                        bottomBar(geoProxy: geo)
                    }
                    .zIndex(1)
                    
                    VStack {
                        if barState == .topFocus {
                            Spacer()
                        }
                        
                        loginRibbon(geoProxy: geo)
                            .bounceTransition(
                                transition: .move(edge: .trailing).combined(with: .opacity),
                                animation: .barAnimation,
                                showView: .init(get: {
                                    !isLoggedIn
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
                                    
                                    barState = .open
                                }
                                .onAppear {
                                    ribbonHeight = ribbonHeight(geoProxy: geo)
                                }
                        
                        if barState == .bottomFocus {
                            Spacer()
                        }
                    }
                    .zIndex(2)
                }
            }
        }
    }
    
    func topBar(geoProxy: GeometryProxy) -> some View {
        HStack {
            Spacer()
            if barState == .closed && !isLoggedIn {
                TopLoginView(mainNamespace: mainNamespace)
                    .padding(.bottom, ribbonHeight / 2)
            } else if barState == .open {
                Image(systemName: "app.gift.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 50)
                    .matchedGeometryEffect(id: "logo", in: mainNamespace)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }
        .frame(height: barHeight(geoProxy: geoProxy, bar: .top))
        .shiftingGlassBackground()
        .shadow(radius: 2)
    }
    
    func bottomBar(geoProxy: GeometryProxy) -> some View {
        HStack {
            Spacer()
            switch barState {
            case .open:
                Button {
                    withAnimation(.spring()) {
                        barState = .bottomFocus
                    }
                } label: {
                    VStack {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        Text("Wishlist")
                            .font(.caption)
                            .bold()
                            .padding(.top, 5)
                    }
                    .padding(10)
                }
                .buttonStyle(DepthButtonStyle(shape: RoundedRectangle(cornerRadius: 15)))
                .matchedGeometryEffect(id: "wishlistButton", in: mainNamespace)
            case .closed:
                if !isLoggedIn {
                    BottomLoginView(loginViewModel: loginViewModel)
                        .padding(.top, ribbonHeight / 2)
                }
            case .topFocus:
                EmptyView()
            case .bottomFocus:
                VStack {
                    ZStack {
                        HStack {
                            Spacer()
                            Text("Wishlist")
                                .font(.title2)
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            Button {
                                withAnimation(.spring()) {
                                    barState = .open
                                }
                            } label: {
                                Image(systemName: "xmark")
                            }
                            .buttonStyle(DepthButtonStyle(shape: Circle()))
                            .matchedGeometryEffect(id: "wishlistButton", in: mainNamespace)
                            .padding()
                        }
                    }
                    VStack(spacing: 15) {
                        Text("This is the wishlist, I guess")
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
            }
            Spacer()
        }
        .frame(height: barHeight(geoProxy: geoProxy, bar: .bottom))
        .shiftingGlassBackground()
        .shadow(radius: 2)
    }
    
    func loginRibbon(geoProxy: GeometryProxy) -> some View {
        VStack {
            Divider()
                .padding(.top)
            Spacer()
            if barState == .closed {
                RibbonLoginView(loginViewModel: loginViewModel)
                    .onAppear {
                        loginViewModel.setLoginSuccess {
                            shouldOpen = true
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
        .offset(CGSize(width: 0, height: barState == .closed ? 0 : -1 * ribbonHeight / 2))
    }
    
    func ribbonHeight(geoProxy: GeometryProxy) -> CGFloat {
        return geoProxy.size.height / 6
    }
    
    func barHeight(geoProxy: GeometryProxy, bar: Bar) -> CGFloat {
        let viewHeight = geoProxy.size.height
        
        switch barState {
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
    ContentView()
        .environmentObject(LoginStorage())
        .environmentObject(AppEnvironment())
}
