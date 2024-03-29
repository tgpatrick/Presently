//
//  Environment.swift
//  Presently
//
//  Created by Thomas Patrick on 9/27/23.
//

import SwiftUI

class AppEnvironment: ObservableObject {
    @AppStorage("CurrentExchangeID") private var exchangeID: String?
    @AppStorage("CurrentPersonID") private var personID: String?
    
    @Published var currentUser: Person?
    @Published var currentExchange: Exchange?
    @Published var userAssignment: Person?
    @Published var allCurrentPeople: People?
    
    @Published var barState: BarState = .closed
    @Published var shouldOpen: Bool = false
    @Published var hideTabBar: Bool = false
    var isOnboarding: Bool {
        return barState == .bottomFocus(.exchangeOnboarding) || barState == .bottomFocus(.personOnboarding)
    }
    
    func getPerson(id: String) -> Person? {
        allCurrentPeople?.first(where: {$0.personId == id})
    }
    
    @MainActor
    func refreshFromServer(exchangeRepo: ExchangeRepository, peopleRepo: PeopleRepository) async {
        if let exchangeID, let personID {
            let _ = await exchangeRepo.get(exchangeID)
            let _ = await peopleRepo.get(exchangeID)
            
            if exchangeRepo.succeeded && peopleRepo.succeeded,
               let user = peopleRepo.storage?.first(where: {
                   $0.personId == personID}) {
                
                withAnimation {
                    currentExchange = exchangeRepo.storage
                    allCurrentPeople = peopleRepo.storage
                    currentUser = user
                    userAssignment = peopleRepo.storage?.getPersonById(user.recipient)
                }
            }
        }
    }
    
    @MainActor
    func replaceCurrentUser(with editedUser: Person) {
        allCurrentPeople?.removeAll(where: { $0 == currentUser })
        allCurrentPeople?.append(editedUser)
        currentUser = editedUser
    }
    
    func logOut() {
        exchangeID = ""
        personID = ""
        currentUser = nil
        currentExchange = nil
        userAssignment = nil
        allCurrentPeople = nil
        barState = .closed
        shouldOpen = false
        hideTabBar = false
    }
}
