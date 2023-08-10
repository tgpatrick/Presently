//
//  LoginViews.swift
//  Presently
//
//  Created by Thomas Patrick on 8/5/23.
//

import SwiftUI

struct TopLoginView: View {
    @State var layout = AnyLayout(VStackLayout())
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                Spacer()
                layout {
                    Image(systemName: "app.gift.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 250)
                    Text("Presently")
                        .font(.title)
                        .bold()
                        .padding()
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
    @FocusState var exchangeIdFieldFocused
    @FocusState var personIdFieldFocused
    @ObservedObject var loginViewModel: LoginViewModel
    
    var body: some View {
        VStack {
            Text("Please enter your code:")
                .bold()
            VStack {
                HStack {
                    Spacer()
                    TextField("", text: $loginViewModel.exchangeIdField)
                        .textFieldStyle(InsetTextFieldStyle())
                        .textContentType(.oneTimeCode)
                        .submitLabel(.next)
                        .frame(width: 75)
                        .padding(.leading)
                        .focused($exchangeIdFieldFocused)
                        .onSubmit {
                            personIdFieldFocused = true
                        }
                        .onChange(of: loginViewModel.exchangeIdField) { _ in
                            if loginViewModel.exchangeIdField.count >= 4 {
                                personIdFieldFocused = true
                            }
                            loginViewModel.onEidChange()
                        }
                    Rectangle()
                        .frame(width: 12, height: 3)
                        .cornerRadius(2)
                    TextField("", text: $loginViewModel.personIdField)
                        .textFieldStyle(InsetTextFieldStyle())
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
                    Spacer()
                }
            }
            Spacer()
        }
        .onAppear {
            loginViewModel.setOnLoginStart {
                exchangeIdFieldFocused = false
                personIdFieldFocused = false
            }
        }
    }
}

struct BottomLoginView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    @StateObject var exchangeRepo = ExchangeRepository()
    @StateObject var peopleRepo = PeopleRepository()
    
    var body: some View {
        VStack {
            if loginViewModel.hasError {
                Text("There was an error logging you in.\nPlease check your code and internet and try again.")
                    .font(.caption)
                    .bold()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.accentColor)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Button(action: loginViewModel.login) {
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
            .buttonStyle(CapsuleButtonStyle())
            .disabled(loginViewModel.isLoading)
            Spacer()
        }
        .padding(.top)
        .onAppear {
            loginViewModel.exchangeRepo = exchangeRepo
            loginViewModel.peopleRepo = peopleRepo
        }
    }
}

struct LoginViews_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
