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
    
    @Published var animating = false
    @Published var animationLength: Double = 5
    @Published var currentPersonIndex: Int = 0
    @Published var animationCurrentPerson: Person?
    @Published var animationCurrentRecipient: String = ""
    @Published var animationAssignedPeople: People = []
    
    @MainActor
    func saveDates(exchangeRepo: ExchangeRepository, environment: AppEnvironment) async {
        guard var editedExchange = environment.currentExchange else { return }
        editedExchange.assignDate = startDate
        editedExchange.theBigDay = giftDate
        await exchangeRepo.put(editedExchange)
        if exchangeRepo.succeeded {
            withAnimation {
                environment.currentExchange?.assignDate = startDate
                environment.currentExchange?.theBigDay = giftDate
                newDate = false
            }
        }
    }
    
    func getShareString() -> String {
        var shareString = ""
        for person in animationAssignedPeople.sorted() {
            shareString += person.name + " -> " + (animationAssignedPeople.getPersonById(person.recipient)?.name ?? "") + "\n"
        }
        return shareString
    }
    
    func assignUploadAndAnimate(environment: AppEnvironment, assignedExchange: Exchange, assignedPeople: People, exchangeRepo: ExchangeRepository, peopleRepo: PeopleRepository) {
        
        if let currentPeople = environment.allCurrentPeople, assignedPeople.count == currentPeople.count {
            animating = true
            
            Task {
                let _ = await exchangeRepo.put(assignedExchange)
                let _ = await peopleRepo.put(assignedPeople)
            }
            
            Timer.scheduledTimer(withTimeInterval: animationLength, repeats: true) { [self] timer1 in
                if let animationCurrentPerson {
                    withAnimation {
                        animationAssignedPeople.insert(animationCurrentPerson, at: 0)
                    }
                }
                withAnimation {
                    animationCurrentPerson = assignedPeople[currentPersonIndex]
                }
                
                currentPersonIndex += 1
                if currentPersonIndex >= assignedPeople.count {
                    currentPersonIndex = 0
                    if let animationCurrentPerson {
                        DispatchQueue.main.asyncAfter(deadline: .now() + animationLength) {
                            withAnimation {
                                self.animationAssignedPeople.insert(animationCurrentPerson, at: 0)
                                self.animationCurrentPerson = nil
                                self.animating = false
                            }
                        }
                    }
                    timer1.invalidate()
                }
            }.fire()
            
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [self] timer2 in
                if !animating {
                    animationCurrentRecipient = ""
                    timer2.invalidate()
                }
                var possibilities = assignedPeople
                possibilities.removeAll(where: { $0.id == animationCurrentPerson?.id })
                withAnimation {
                    animationCurrentRecipient = possibilities.randomElement()?.name ?? ""
                }
            }.fire()
            
            environment.currentExchange = assignedExchange
            environment.allCurrentPeople = assignedPeople
        }
    }
    
    func assignGifts(exchange: Exchange, people: People) -> (Bool, Exchange, People) {
        var assignedExchange = exchange
        var assignedPeople = people
        let thisYear = Calendar.current.component(.year, from: Date())
        
        func canGive(_ thisPerson: Person, to thatPerson: Person) -> Bool {
            if thisPerson.id == thatPerson.id
                || thisPerson.exceptions.contains(thatPerson.id)
                || thatPerson.recipient == thisPerson.id {
                return false
            }
            for gift in thisPerson.giftHistory {
                if thisYear - gift.year <= exchange.yearsWithoutRepeat
                    && gift.recipientId == thatPerson.id {
                    return false
                }
            }
            return true
        }
        
        func giftHelper(
            _ needToGive: People = people,
            _ needToReceive: People = people,
            _ assignedMembers: People = []
        ) -> Bool {
            if needToGive.count == 0 {
                assignedPeople = assignedMembers
                assignedExchange.started = true
                assignedExchange.year = thisYear
                return true
            }
            
            for person in needToGive {
                var possibleRecipients = needToReceive
                possibleRecipients.removeAll(where: {!canGive(person, to: $0)})
                
                if possibleRecipients.count > 0 {
                    let recipient = possibleRecipients.randomElement()!
                    var giver = person
                    giver.recipient = recipient.id
                    
                    var needToGiveCopy = needToGive
                    var needToReceiveCopy = needToReceive
                    var assignedMembersCopy = assignedMembers
                    needToGiveCopy.removeAll(where: {$0.id == giver.id})
                    needToReceiveCopy.removeAll(where: {$0.id == recipient.id})
                    // Dear future self: this is so that the "giver's" recipient
                    // is saved in a place that canGive() can see it.
                    if needToReceiveCopy.contains(where: {$0.id == giver.id}) {
                        needToReceiveCopy.removeAll(where: {$0.id == giver.id})
                        needToReceiveCopy.append(giver)
                    }
                    assignedMembersCopy.append(giver)
                    
                    if giftHelper(needToGiveCopy, needToReceiveCopy, assignedMembersCopy) {
                        return true
                    }
                } else {
                    return false
                }
            }
            return false
        }
        
        return (giftHelper(), assignedExchange, assignedPeople.shuffled())
    }
}
