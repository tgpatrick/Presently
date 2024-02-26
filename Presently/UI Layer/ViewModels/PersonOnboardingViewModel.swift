//
//  PersonOnboardingViewModel.swift
//  Presently
//
//  Created by Thomas Patrick on 11/3/23.
//

import Foundation

class PersonOnboardingViewModel: OnboardingViewModel {
    @Published var greeting = ""
    @Published var wishList = [WishListItem]()
    @Published var giftHistory = [HistoricalGift]()
    @Published var exclusions = [String]()
    @Published var initialized = false
    
    @Published var scrollPosition: Int? = 0
    @Published var hideButtons = false
    @Published var canProceedTo: Int = .max
    
    func save(repository: any Repository, environment: AppEnvironment) async {
        guard var editedPerson = environment.currentUser, let personRepo = repository as? PersonRepository else { return }
        editedPerson.greeting = greeting
        editedPerson.wishList = wishList
        editedPerson.giftHistory = giftHistory
        editedPerson.exceptions = exclusions
        await finish(personRepo: personRepo, environment: environment, person: editedPerson)
    }
    
    func finish(personRepo: PersonRepository, environment: AppEnvironment, person: Person) async {
        var editedPerson = person
        editedPerson.setUp = true
        if editedPerson != environment.currentUser {
            await personRepo.put(editedPerson)
            if personRepo.succeeded {
                await environment.replaceCurrentUser(with: editedPerson)
            }
        } else {
            personRepo.manualSuccess()
        }
    }
}

