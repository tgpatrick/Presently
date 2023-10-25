//
//  ProfileViewModel.swift
//  Presently
//
//  Created by Thomas Patrick on 10/24/23.
//

import Foundation

class ProfileViewModel: ObservableObject {
    func saveIntro(personRepo: PersonRepository, environment: AppEnvironment, newIntro: String) {
        Task {
            guard var editedPerson = environment.currentUser else { return }
            if editedPerson.greeting != newIntro {
                editedPerson.greeting = newIntro
                await saveAndFetch(personRepo: personRepo, environment: environment, editedPerson: editedPerson)
            } else {
                personRepo.loadingState = .success
            }
        }
    }
    
    func saveWishList(personRepo: PersonRepository, environment: AppEnvironment, oldWish: WishListItem, newWish: WishListItem) {
        Task {
            guard var editedPerson = environment.currentUser else { return }
            if oldWish != newWish {
                editedPerson.wishList.removeAll(where: { $0 == oldWish })
                editedPerson.wishList.append(newWish)
                await saveAndFetch(personRepo: personRepo, environment: environment, editedPerson: editedPerson)
            } else {
                personRepo.loadingState = .success
            }
        }
    }
    
    private func saveAndFetch(personRepo: PersonRepository, environment: AppEnvironment, editedPerson: Person) async {
        await personRepo.put(editedPerson)
        if case .success = personRepo.loadingState {
            environment.allCurrentPeople?.removeAll(where: { $0 == environment.currentUser })
            environment.allCurrentPeople?.append(editedPerson)
        }
    }
}
