//
//  ProfileViewModel.swift
//  Presently
//
//  Created by Thomas Patrick on 10/24/23.
//

import Foundation

enum LastRequest {
    case intro
    case wishList
}

class ProfileViewModel: ObservableObject {
    @Published var lastRequest: LastRequest?
    
    func saveIntro(personRepo: PersonRepository, environment: AppEnvironment, newIntro: String) async {
        guard var editedPerson = environment.currentUser else { return }
        if editedPerson.greeting != newIntro {
            editedPerson.greeting = newIntro
            await putAndSave(personRepo: personRepo, environment: environment, editedPerson: editedPerson)
        } else {
            personRepo.manualSuccess()
        }
    }
    
    func saveWishList(personRepo: PersonRepository, environment: AppEnvironment, oldWish: WishListItem?, newWish: WishListItem) async {
        guard var editedPerson = environment.currentUser else { return }
        if oldWish != newWish {
            editedPerson.wishList.removeAll(where: { $0 == oldWish })
            editedPerson.wishList.append(newWish)
            await putAndSave(personRepo: personRepo, environment: environment, editedPerson: editedPerson)
        } else {
            personRepo.manualSuccess()
        }
    }
    
    func deleteWish(personRepo: PersonRepository, environment: AppEnvironment, wish: WishListItem) async {
        guard var editedPerson = environment.currentUser else { return }
        editedPerson.wishList.removeAll(where: { $0 == wish })
        await putAndSave(personRepo: personRepo, environment: environment, editedPerson: editedPerson)
    }
    
    func saveGift(personRepo: PersonRepository, environment: AppEnvironment, oldGift: HistoricalGift?, newGift: HistoricalGift) async {
        guard var editedPerson = environment.currentUser else { return }
        if oldGift != newGift {
            editedPerson.giftHistory.removeAll(where: { $0 == oldGift })
            editedPerson.giftHistory.append(newGift)
            await putAndSave(personRepo: personRepo, environment: environment, editedPerson: editedPerson)
        } else {
            personRepo.manualSuccess()
        }
    }
    
    func deleteGift(personRepo: PersonRepository, environment: AppEnvironment, gift: HistoricalGift) async {
        guard var editedPerson = environment.currentUser else { return }
        if editedPerson.giftHistory.contains(where: { $0 == gift }) {
            editedPerson.giftHistory.removeAll(where: { $0 == gift })
            await putAndSave(personRepo: personRepo, environment: environment, editedPerson: editedPerson)
        } else {
            personRepo.manualSuccess()
        }
    }
    
    func saveExclusion(personRepo: PersonRepository, environment: AppEnvironment, exclusion: String) async {
        guard var editedPerson = environment.currentUser else { return }
        if !editedPerson.exceptions.contains(where: { $0 == exclusion }) {
            editedPerson.exceptions.append(exclusion)
            await putAndSave(personRepo: personRepo, environment: environment, editedPerson: editedPerson)
        } else {
            personRepo.manualSuccess()
        }
    }
    
    func deleteExclusion(personRepo: PersonRepository, environment: AppEnvironment, exclusion: String) async {
        guard var editedPerson = environment.currentUser else { return }
        if editedPerson.exceptions.contains(where: { $0 == exclusion }) {
            editedPerson.exceptions.removeAll(where: { $0 == exclusion })
            await putAndSave(personRepo: personRepo, environment: environment, editedPerson: editedPerson)
        } else {
            personRepo.manualSuccess()
        }
    }
    
    private func putAndSave(personRepo: PersonRepository, environment: AppEnvironment, editedPerson: Person) async {
        await personRepo.put(editedPerson)
        if personRepo.succeeded {
            await environment.replaceCurrentUser(with: editedPerson)
        }
    }
}
