//
//  LoginViews.swift
//  Presently
//
//  Created by Thomas Patrick on 8/5/23.
//

import SwiftUI

struct TopLoginView: View {
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
                        .frame(maxHeight: 250)
                        .matchedGeometryEffect(id: "logo", in: mainNamespace)
                        .accessibilityIdentifier("logo")
                    Text("Presently")
                        .font(.title)
                        .bold()
                        .padding()
                        .matchedGeometryEffect(id: "appName", in: mainNamespace)
                }
                .onChange(of: geo.size.height) { newValue in
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
    
    @FocusState var exchangeIdFieldFocused
    @FocusState var personIdFieldFocused
    @ObservedObject var loginViewModel: LoginViewModel
    
    var body: some View {
        VStack {
            Text("Please enter your code:")
                .bold()
            if exchangeID?.count ?? 0 < 4 || personID?.count ?? 0 < 4 || loginViewModel.hasError {
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
                        .onChange(of: loginViewModel.exchangeIdField) { _ in
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
                            loginViewModel.login()
                        }
                        .onChange(of: loginViewModel.personIdField) { _ in
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
            if let exchangeID, let personID {
                loginViewModel.exchangeIdField = exchangeID
                loginViewModel.personIdField = personID
                loginViewModel.login()
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
    
    @EnvironmentObject var environment: AppEnvironment
    @StateObject var exchangeRepo = ExchangeRepository()
    @StateObject var peopleRepo = PeopleRepository()
    @ObservedObject var loginViewModel: LoginViewModel
    
    var body: some View {
        VStack {
            if loginViewModel.hasError {
                Text("There was an error logging you in.\nPlease check your code and internet and try again.")
                    .font(.caption)
                    .bold()
                    .multilineTextAlignment(.center)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .mainContentBox(material: .ultraThin)
                    .padding(.bottom, 5)
            }
            if exchangeID?.count ?? 0 < 4 || personID?.count ?? 0 < 4 || loginViewModel.hasError {
                Button {
                    loginViewModel.login()
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
            Spacer()
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
