//
//  TopBar.swift
//  Presently
//
//  Created by Thomas Patrick on 9/30/23.
//

import SwiftUI

struct TopBar: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var environment: AppEnvironment
    @Namespace var topNamespace
    @State var ribbonHeight: CGFloat
    
    var body: some View {
        VStack {
            if environment.barState == .closed {
                TopLoginView(mainNamespace: topNamespace)
                    .padding(.bottom, ribbonHeight / 2)
            } else if environment.barState == .open {
                topBarOpen
            } else if environment.barState == .topFocus {
                VStack {
                    ZStack(alignment: .topTrailing) {
                        HStack {
                            Spacer()
                            Text("Settings")
                                .font(.title)
                                .bold()
                                .matchedGeometryEffect(id: "appName", in: topNamespace)
                            Spacer()
                        }
                        .padding(.vertical)
                        
                        Button {
                            withAnimation(.spring()) {
                                environment.barState = .open
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .bold()
                        }
                        .matchedGeometryEffect(id: "topButton", in: topNamespace)
                        .padding()
                    }
                    Spacer()
                    Button {
                        environment.logOut()
                    } label: {
                        Text("Log Out")
                            .font(.title2)
                            .bold()
                            .padding(5)
                    }
                    Spacer()
                }
                .buttonStyle(DepthButtonStyle())
            }
        }
        .fillHorizontally()
    }
    
    var topBarOpen: some View {
        HStack {
            Spacer()
            Image(.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .if(colorScheme == .dark) { $0.colorInvert() }
                .frame(maxHeight: 50)
                .matchedGeometryEffect(id: "logo", in: topNamespace)
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.vertical, 5)
            Text("Presently")
                .font(.largeTitle)
                .bold()
                .fixedSize(horizontal: true, vertical: false)
                .matchedGeometryEffect(id: "appName", in: topNamespace)
            Spacer()
            Button {
                withAnimation(.spring()) {
                    environment.barState = .topFocus
                }
            } label: {
                Image(systemName: "gear")
                    .resizable()
                    .fontWeight(.bold)
                    .aspectRatio(contentMode: .fit)
                    .padding(.vertical, 12)
            }
            .shadow(radius: 1)
            .shadow(radius: 1)
            .foregroundStyle(Color(.accentLight))
            .matchedGeometryEffect(id: "topButton", in: topNamespace)
        }
        .padding(.horizontal)
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
