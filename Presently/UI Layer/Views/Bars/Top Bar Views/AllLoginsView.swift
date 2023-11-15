//
//  AllLoginsView.swift
//  Presently
//
//  Created by Thomas Patrick on 11/12/23.
//

import SwiftUI

struct AllLoginsView: View {
    @EnvironmentObject var environment: AppEnvironment
    @EnvironmentObject var loginStorage: LoginStorage
    
    @StateObject var loginViewModel = LoginViewModel()
    @StateObject var exchangeRepo = ExchangeRepository()
    @StateObject var peopleRepo = PeopleRepository()
    
    @Namespace var allLoginsNamespace
    @State var showRibbon = false
    @State private var ribbonHeight: CGFloat = 125
    @State private var ribbonWidth: CGFloat = .zero
    
    var body: some View {
        ZStack {
            VStack {
                if let currentUser = environment.currentUser {
                    VStack(spacing: 25) {
                        if loginStorage.isLoading {
                            ProgressView()
                        } else {
                            SectionView(title: "Your current exchange") {
                                if let currentItem = loginStorage.items.first(where: { $0.exchangeID == currentUser.exchangeId && $0.personID == currentUser.personId }) {
                                    loginItem(item: currentItem)
                                }
                            }
                            if loginStorage.items.count > 1 {
                                SectionView(title: "Your other exchanges") {
                                    ScrollView {
                                        ForEach(loginStorage.items) { item in
                                            if item.exchangeID != currentUser.exchangeId || item.personID != currentUser.personId {
                                                VStack {
                                                    loginItem(item: item, current: false)
                                                        .padding(.vertical, 5)
                                                }
                                                .animation(.easeInOut, value: loginStorage.items)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                HStack {
                    if loginStorage.items.count == 1 {
                        Spacer()
                        Button {
                            environment.logOut()
                        } label: {
                            Text("Log Out")
                                .font(.title2)
                                .bold()
                                .padding(5)
                        }
                    }
                    Spacer()
                    if !showRibbon {
                        Button {
                            withAnimation(.bouncy) {
                                showRibbon = true
                            }
                        } label: {
                            Text("Add Another")
                                .font(.title2)
                                .bold()
                                .padding(5)
                        }
                        .matchedGeometryEffect(id: "LoginButton", in: allLoginsNamespace)
                        Spacer()
                    }
                }
            }
            .blur(radius: showRibbon ? 10 : 0)
            .disabled(showRibbon)
            .background {
                GeometryReader { geo in
                    Color.clear.onAppear {
                        ribbonWidth = geo.size.width
                    }
                }
            }
            .onAppear {
                Task {
                    await loginStorage.load()
                }
                loginViewModel.environment = environment
                loginViewModel.exchangeRepo = exchangeRepo
                loginViewModel.peopleRepo = peopleRepo
            }
            
            VStack {
                VStack {
                    Divider()
                        .padding(.top)
                    Spacer()
                    RibbonLoginView(loginViewModel: loginViewModel, fromSettings: true)
                    Spacer()
                    Divider()
                        .padding(.bottom)
                }
                .frame(height: ribbonHeight)
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
                            .offset(CGSize(width: ribbonWidth - ribbonHeight / 1.75 - 10, height: 0))
                            .shadow(radius: 5, x: 10)
                    }
                }
                .bounceTransition(
                    transition: .opacity.combined(with: .move(edge: .trailing)),
                    animation: .barAnimation,
                    showView: $showRibbon,
                    onDismiss: {})
                
                if showRibbon {
                    HStack {
                        Button("Cancel") {
                            withAnimation {
                                showRibbon = false
                            }
                        }
                        Button {
                            loginViewModel.setLoginSuccess {
                                withAnimation {
                                    showRibbon = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if let currentUser = environment.currentUser, !currentUser.setUp {
                                        withAnimation(.bouncy) {
                                            environment.showOnboarding = true
                                            environment.barState = .bottomFocus
                                        }
                                    }
                                }
                            }
                            loginViewModel.login(loginStorage: loginStorage)
                        } label: {
                            if loginViewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("Log in")
                            }
                        }
                    }
                    .matchedGeometryEffect(id: "LoginButton", in: allLoginsNamespace)
                }
            }
        }
        .buttonStyle(DepthButtonStyle())
    }
    
    func loginItem(item: LoginStorageItem, current: Bool = true) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.exchangeName)
                    .font(.title2)
                    .bold()
                Text(item.personName)
                    .font(.title3)
                if !current {
                    HStack {
                        Spacer()
                        Button {
                            loginViewModel.exchangeIdField = item.exchangeID
                            loginViewModel.personIdField = item.personID
                            loginViewModel.login(loginStorage: loginStorage)
                        } label: {
                            if exchangeRepo.isLoading || peopleRepo.isLoading {
                                ProgressView()
                            } else {
                                Text("Switch")
                            }
                        }
                        .buttonStyle(DepthButtonStyle(backgroundColor: .green))
                        Spacer()
                        Button {
                            Task {
                                await loginStorage.delete(item)
                            }
                        } label: {
                            if loginStorage.isLoading {
                                ProgressView()
                            } else {
                                Text("Delete")
                            }
                        }
                        .buttonStyle(DepthButtonStyle(backgroundColor: .red))
                        Spacer()
                    }
                    .foregroundStyle(Color.black)
                    .bold()
                }
            }
            Spacer()
        }
        .mainContentBox()
    }
}

#Preview {
    let environment = AppEnvironment()
    let loginStorage = LoginStorage()
    
    return ZStack {
        ShiftingBackground()
            .ignoresSafeArea()
        AllLoginsView()
    }
    .environmentObject(environment)
    .environmentObject(loginStorage)
    .onAppear {
        environment.currentUser = testPerson
        
        loginStorage.items = [
            LoginStorageItem(
                exchangeName: "Exchange 1",
                personName: "Person 1",
                exchangeID: "0001",
                personID: "0001"),
            LoginStorageItem(
                exchangeName: "Exchange 2",
                personName: "Person 2",
                exchangeID: "0002",
                personID: "0002")
        ]
    }
}
