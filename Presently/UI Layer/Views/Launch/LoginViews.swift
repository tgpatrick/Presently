//
//  LoginViews.swift
//  Presently
//
//  Created by Thomas Patrick on 8/5/23.
//

import SwiftUI

struct TopLoginView: View {
    @Environment(\.colorScheme) private var colorScheme
    var mainNamespace: Namespace.ID
    @State var layout = AnyLayout(VStackLayout())
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                Spacer()
                layout {
                    Image(.logo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .if(colorScheme == .dark) { $0.colorInvert() }
                        .frame(maxHeight: 250)
                        .matchedGeometryEffect(id: "logo", in: mainNamespace)
                        .accessibilityIdentifier("logo")
                    Text("Presently")
                        .font(.title)
                        .bold()
                        .padding()
                        .matchedGeometryEffect(id: "appName", in: mainNamespace)
                }
                .onChange(of: geo.size.height) { _, newValue in
                    withAnimation {
                        if newValue < 200 {
                            layout = AnyLayout(HStackLayout())
                        } else {
                            layout = AnyLayout(VStackLayout())
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(.vertical, 50)
    }
}

struct RibbonLoginView: View {
    @AppStorage("CurrentExchangeID") private var exchangeID: String?
    @AppStorage("CurrentPersonID") private var personID: String?
    
    @EnvironmentObject var loginStorage: LoginStorage
    
    @FocusState private var exchangeIdFieldFocused
    @FocusState private var personIdFieldFocused
    @ObservedObject var loginViewModel: LoginViewModel
    @State var fromSettings = false
    
    var body: some View {
        VStack {
            Spacer()
            if fromSettings || exchangeID?.count ?? 0 < 4 || personID?.count ?? 0 < 4 || loginViewModel.hasError {
                Text("Please enter your code:")
                    .bold()
                HStack {
                    Spacer()
                    TextField("", text: $loginViewModel.exchangeIdField)
                        .textContentType(.oneTimeCode)
                        .submitLabel(.next)
                        .frame(width: 75)
                        .padding(.leading)
                        .focused($exchangeIdFieldFocused)
                        .onSubmit {
                            personIdFieldFocused = true
                        }
                        .onChange(of: loginViewModel.exchangeIdField) {
                            if exchangeIdFieldFocused && loginViewModel.exchangeIdField.count >= 4 {
                                personIdFieldFocused = true
                            }
                            loginViewModel.onEidChange()
                        }
                        .accessibilityIdentifier("exchangeIdTextField")
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 12, height: 3)
                    TextField("", text: $loginViewModel.personIdField)
                        .textContentType(.oneTimeCode)
                        .submitLabel(.go)
                        .frame(width: 75)
                        .padding(.trailing)
                        .focused($personIdFieldFocused)
                        .onSubmit {
                            exchangeIdFieldFocused = false
                            loginViewModel.login(loginStorage: loginStorage)
                        }
                        .onChange(of: loginViewModel.personIdField) {
                            loginViewModel.onPidChange()
                        }
                        .accessibilityIdentifier("personIdTextField")
                    Spacer()
                }
                .textFieldStyle(InsetTextFieldStyle())
            } else {
                ProgressView()
            }
            Spacer()
        }
        .onAppear {
            if let exchangeID, let personID, !fromSettings {
                loginViewModel.exchangeIdField = exchangeID
                loginViewModel.personIdField = personID
                loginViewModel.login(loginStorage: loginStorage)
            }
            loginViewModel.setOnLoginStart {
                exchangeIdFieldFocused = false
                personIdFieldFocused = false
            }
        }
    }
}

struct BottomLoginView: View {
    @AppStorage("CurrentExchangeID") private var exchangeID: String?
    @AppStorage("CurrentPersonID") private var personID: String?
    
    @EnvironmentObject var loginStorage: LoginStorage
    @EnvironmentObject var environment: AppEnvironment
    
    @StateObject var exchangeRepo = ExchangeRepository()
    @StateObject var peopleRepo = PeopleRepository()
    @ObservedObject var loginViewModel: LoginViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            if loginViewModel.hasError {
                Text("There was an error logging you in.\nPlease check your code and internet and try again.")
                    .font(.caption)
                    .bold()
                    .multilineTextAlignment(.center)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .mainContentBox(material: .ultraThin)
            }
            
            if exchangeID?.count ?? 0 < 4 || personID?.count ?? 0 < 4 || loginViewModel.hasError {
                Button {
                    loginViewModel.login(loginStorage: loginStorage)
                } label: {
                    Group {
                        if !loginViewModel.isLoading {
                            Text("Log in")
                                .bold()
                                .frame(width: 100)
                        } else {
                            ProgressView()
                                .frame(width: 100)
                                .transition(.opacity)
                        }
                    }
                }
                .buttonStyle(DepthButtonStyle())
                .disabled(loginViewModel.isLoading)
                .transition(.opacity)
                .accessibilityIdentifier("LoginButton")
            }
            
            if exchangeID?.count ?? 0 < 4 || personID?.count ?? 0 < 4 || loginViewModel.hasError {
                Button {
                    withAnimation {
                        environment.barState = .bottomFocus(.exchangeOnboarding)
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text("Create a new exchange")
                        Image(systemName: "chevron.forward")
                    }
                    .fontWeight(.heavy)
                }
                .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(.top)
        .onAppear {
            loginViewModel.environment = environment
            loginViewModel.exchangeRepo = exchangeRepo
            loginViewModel.peopleRepo = peopleRepo
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
