//
//  LoginViewModel.swift
//  Presently
//
//  Created by Thomas Patrick on 8/5/23.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    @AppStorage("CurrentExchangeID") private var exchangeID: String?
    @AppStorage("CurrentPersonID") private var personID: String?
    
    @Published var environment = AppEnvironment()
    @Published var exchangeRepo = ExchangeRepository()
    @Published var peopleRepo = PeopleRepository()
    @Published var exchangeIdField = ""
    @Published var personIdField = ""
    @Published var forceUpdate = false
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
    
    @MainActor
    func login(loginStorage: LoginStorage) {
        if let onLoginStart {
            withAnimation {
                onLoginStart()
            }
        }
        if exchangeIdField != "" && personIdField != "" {
            Task {
                let _ = await exchangeRepo.get(exchangeIdField)
                let _ = await peopleRepo.get(exchangeIdField)
                let _ = await loginStorage.load()
                
                if exchangeRepo.succeeded && peopleRepo.succeeded,
                   let user = peopleRepo.storage?.first(where: {
                       $0.personId == personIdField}) {
                    
                    if let exchange = exchangeRepo.storage, let people = peopleRepo.storage, let person = people.getPersonById(personIdField) {
                        let loginItem = LoginStorageItem(
                            exchangeName: exchange.name,
                            personName: person.name,
                            exchangeID: person.exchangeId,
                            personID: person.personId)
                        if !loginStorage.items.contains(where: { $0 == loginItem }) {
                            await loginStorage.save(loginItem)
                        }
                    }
                    
                    exchangeID = exchangeIdField
                    personID = personIdField
                    exchangeIdField = ""
                    personIdField = ""
                    withAnimation(.linear) {
                        environment.currentExchange = exchangeRepo.storage
                        environment.allCurrentPeople = peopleRepo.storage
                        environment.currentUser = user
                        environment.userAssignment = peopleRepo.storage?.first(where: {
                            $0.personId == user.recipient
                        })
                        
                        if let onLoginSuccess {
                            withAnimation {
                                onLoginSuccess()
                            }
                        }
                    }
                } else {
                    forceUpdate.toggle()
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
