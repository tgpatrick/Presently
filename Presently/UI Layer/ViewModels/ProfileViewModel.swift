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
    
    private func putAndSave(personRepo: PersonRepository, environment: AppEnvironment, editedPerson: Person) async {
        await personRepo.put(editedPerson)
        if case .success = personRepo.loadingState {
            await environment.replaceCurrentUser(with: editedPerson)
        }
    }
}
