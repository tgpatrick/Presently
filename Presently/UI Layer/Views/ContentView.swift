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
    var isLoggedIn: Bool {
        exchangeID != nil || personID != nil
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                //TODO: change to isLoggedIn
                if barState == .open {
                    ScrollView {
                        Text("Inside Stuff")
                            .padding(.top, geo.size.height / 10)
                            .padding(.bottom, geo.size.height / 15)
                    }
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
                        //TODO: change to isLoggedIn
                        if barState != .open {
                            loginRibbon(geoProxy: geo)
                                .bounceTransition(transition: .move(edge: .trailing).combined(with: .opacity), animation: .barAnimation, shouldStartTransition: $shouldOpen) {
                                    barState = .open
                                }
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
            if barState != .closed {
                Button(action: {
                    withAnimation(.barAnimation) {
                        if barState == .topFocus {
                            barState = .open
                        } else {
                            barState = .topFocus
                        }
                    }
                }) {
                    if barState == .topFocus {
                        Text("Open")
                    } else {
                        Text("Focus")
                    }
                }
                Spacer()
            }
        }
        .frame(height: barHeight(geoProxy: geoProxy, bar: .top))
        .backgroundStyle(.thickMaterial)
        .background(ShiftingBackground().opacity(barState == .open ? 0.9 : 1))
        .shadow(radius: 2)
    }
    
    func bottomBar(geoProxy: GeometryProxy) -> some View {
        HStack {
            Spacer()
            Button(action: {
                withAnimation(.barAnimation) {
                    if barState == .bottomFocus {
                        barState = .open
                    } else {
                        barState = .bottomFocus
                    }
                }
            }) {
                if barState == .bottomFocus {
                    Text("Open")
                } else {
                    Text("Focus")
                }
            }
            Spacer()
        }
        .frame(height: barHeight(geoProxy: geoProxy, bar: .bottom))
        .backgroundStyle(.thickMaterial)
        .background(ShiftingBackground().opacity(barState == .open ? 0.9 : 1))
        .shadow(radius: 2)
    }
    
    func loginRibbon(geoProxy: GeometryProxy) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(.red)
                .mask(RibbonShape())
                .offset(CGSize(width: -1 * ribbonHeight(geoProxy: geoProxy), height: 0))
                .shadow(radius: 5)
            
            Rectangle()
                .foregroundColor(.red)
                .offset(CGSize(width: geoProxy.size.width - ribbonHeight(geoProxy: geoProxy), height: 0))
                .shadow(radius: 5)
            
            VStack {
                Divider()
                    .padding(.top)
                Spacer()
                HStack {
                    Spacer()
                    Button("Open") {
                        shouldOpen = true
                    }
                    Spacer()
                }
                .padding(.vertical)
                Spacer()
                Divider()
                    .padding(.bottom)
            }
            .background(Color.red)
        }
        .frame(height: ribbonHeight(geoProxy: geoProxy))
        .offset(CGSize(width: 0, height: barState == .closed ? 0 : -1 * ribbonHeight(geoProxy: geoProxy) / 2))
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
