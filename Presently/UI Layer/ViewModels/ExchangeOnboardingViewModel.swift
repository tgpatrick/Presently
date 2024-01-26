//
//  ExchangeOnboardingViewModel.swift
//  Presently
//
//  Created by Thomas Patrick on 1/24/24.
//

import Foundation

class ExchangeOnboardingViewModel: OnboardingViewModel {
    @Published var id: String = ""
    @Published var name: String = ""
    @Published var intro: String = ""
    @Published var rules: String = ""
    @Published var startDate: Date = Date()
    @Published var assignDate: Date? = nil
    @Published var theBigDay: Date? = nil
    private let year: Int = Calendar.current.component(.year, from: .now)
    @Published var secret: Bool = false
    @Published var repeating: Bool = true
    private let started: Bool = false
    @Published var yearsWithoutRepeat: Int = 0
    @Published var people: People = []
    @Published var organizer: Person? = nil
    
    @Published var scrollPosition: Int? = 0
    @Published var hideButtons: Bool = false
    @Published var canProceedTo: Int = .max
    
    func generateID() -> String {
        let possibleChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString = String((0..<4).map{ _ in possibleChars.randomElement()! })
        return randomString
    }
    
    func save(repository: any Repository, environment: AppEnvironment) async {
        guard let organizer = organizer, let exchangeRepo = repository as? ExchangeRepository else { return }
        let newExchange = Exchange(id: id, name: name, intro: intro, rules: rules, startDate: startDate, assignDate: assignDate, theBigDay: theBigDay, year: year, secret: secret, repeating: repeating, started: started, members: [], organizers: [], yearsWithoutRepeat: yearsWithoutRepeat)
        await finish(exchangeRepo: exchangeRepo, environment: environment, exchange: newExchange, people: people, organizer: organizer)
    }
    
    func finish(exchangeRepo: ExchangeRepository, environment: AppEnvironment, exchange: Exchange, people: People, organizer: Person) async {
        await exchangeRepo.put(exchange)
        if exchangeRepo.succeeded {
            environment.currentExchange = exchange
            environment.allCurrentPeople = people
            environment.currentUser = organizer
        }
    }
}
