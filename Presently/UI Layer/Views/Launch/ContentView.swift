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
    @AppStorage("CurrentExchangeID") var exchangeID: String?
    @AppStorage("CurrentPersonID") var personID: String?
    @State var barState: BarState = .closed
    @State var shouldOpen: Bool = false
    @StateObject var scrollViewModel = ScrollViewModel()
    @StateObject var loginViewModel = LoginViewModel()
    @Namespace var mainNamespace
    var isLoggedIn: Bool {
        exchangeID != nil || personID != nil
    }
    @State var ribbonHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                //TODO: change to isLoggedIn
                if barState != .closed {
                    NavigationScrollView(
                        viewModel: scrollViewModel,
                        items: [
                            ExchangeView(viewModel: scrollViewModel),
                            NextDateView(viewModel: scrollViewModel),
                            AssignedPersonView(viewModel: scrollViewModel),
                            TestNavItem(viewModel: scrollViewModel)
                        ],
                        topInset: barHeight(geoProxy: geo, bar: .top),
                        bottomInset: barHeight(geoProxy: geo, bar: .bottom))
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
                                    //TODO: change to isLoggedIn
                                    !shouldOpen
                                }, set: { _ in })) {
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
                    .foregroundColor(Color(.accentBackground))
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
                    .foregroundColor(Color(.accentBackground))
                    .offset(CGSize(width: geoProxy.size.width - ribbonHeight / 1.75, height: 0))
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
            return bar == .top ? viewHeight / 10 : viewHeight / 15
        case .closed:
            return viewHeight / 2
        case .topFocus:
            return bar == .top ? viewHeight : 0
        case .bottomFocus:
            return bar == .bottom ? viewHeight : 0
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LoginStorage())
    }
}
