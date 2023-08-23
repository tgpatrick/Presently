//
//  LoginViewModel.swift
//  Presently
//
//  Created by Thomas Patrick on 8/5/23.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    @AppStorage("CurrentExchangeID") var exchangeID: String?
    @AppStorage("CurrentPersonID") var personID: String?
    @Published var exchangeRepo = ExchangeRepository()
    @Published var peopleRepo = PeopleRepository()
    @Published var exchangeIdField = ""
    @Published var personIdField = ""
    var onLoginStart: (() -> Void)?
    var onLoginSuccess: (() -> Void)?
    var isLoading: Bool {
        exchangeRepo.isLoading || exchangeRepo.isLoading
    }
    var hasError: Bool {
        if case .error = exchangeRepo.loadingState {
            return true
        }
        if case .error = exchangeRepo.loadingState {
            return true
        }
        return false
    }
    
    func setOnLoginStart(to function: @escaping () -> Void) {
        onLoginStart = function
    }
    
    func setLoginSuccess(to function: @escaping () -> Void) {
        onLoginSuccess = function
    }
    
    func login() {
        withAnimation {
            if let onLoginStart {
                onLoginStart()
            }
            exchangeRepo.loadingState = .loading
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            if Int.random(in: 1...10) != 1 {
                exchangeRepo.loadingState = .success
                if let onLoginSuccess {
                    onLoginSuccess()
                }
            } else {
                withAnimation(.easeInOut) {
                    exchangeRepo.loadingState = .error(ErrorWrapper(error: NetworkError.serverError(code: 1, url: "www.apple.com"), guidance: "Nothing"))
                }
            }
        }
    }
    
    func onEidChange() {
        exchangeIdField = exchangeIdField.filter { "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".contains($0) }
        exchangeIdField = exchangeIdField.uppercased()
        if exchangeIdField.count > 4 {
            let startExtraIndex = exchangeIdField.index(exchangeIdField.startIndex, offsetBy: 4)
            personIdField = String(exchangeIdField[startExtraIndex...])
            exchangeIdField = String(exchangeIdField.prefix(4))
        }
    }
    
    func onPidChange() {
        personIdField = personIdField.filter { "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".contains($0) }
        personIdField = personIdField.uppercased()
        if personIdField.count >= 8 {
            exchangeIdField = String(personIdField.prefix(4))
            let startExtraIndex = personIdField.index(exchangeIdField.startIndex, offsetBy: 4)
            personIdField = String(personIdField[startExtraIndex...])
        }
        if personIdField.count > 4 {
            personIdField = String(personIdField.prefix(4))
        }
    }
}
