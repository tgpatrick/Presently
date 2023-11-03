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
    @Published var allCurrentPeople: [Person]?
    
    @Published var barState: BarState = .closed
    @Published var shouldOpen: Bool = false
    @Published var showOnboarding: Bool = false
    @Published var hideTabBar: Bool = false
    
    func getPerson(id: String) -> Person? {
        allCurrentPeople?.first(where: {$0.personId == id})
    }
    
    func refreshFromServer(exchangeRepo: ExchangeRepository, peopleRepo: PeopleRepository) async {
        if let exchangeID, let personID {
            let _ = await exchangeRepo.get(exchangeID)
            let _ = await peopleRepo.get(exchangeID)
            
            if case .success = exchangeRepo.loadingState,
               case .success = peopleRepo.loadingState,
               let user = peopleRepo.storage?.first(where: {
                   $0.personId == personID}) {
                
                DispatchQueue.main.async { [self] in
                    currentExchange = exchangeRepo.storage
                    allCurrentPeople = peopleRepo.storage
                    currentUser = user
                    userAssignment = peopleRepo.storage?.first(where: {
                        $0.personId == user.recipient
                    })
                }
            }
        }
    }
}
