//
//  OrganizerViewModel.swift
//  Presently
//
//  Created by Thomas Patrick on 11/7/23.
//

import SwiftUI

class OrganizerViewModel: ObservableObject {
    @Published var startDate: Date = Date.now
    @Published var giftDate: Date = Date.now
    @Published var newDate = false
    
    func saveDates(exchangeRepo: ExchangeRepository, environment: AppEnvironment) async {
        guard var editedExchange = environment.currentExchange else { return }
        editedExchange.assignDate = startDate
        editedExchange.theBigDay = giftDate
        await exchangeRepo.put(editedExchange)
    }
}
