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

    @Published var showEndWarning: Bool = false

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

    func getShareString(from people: People? = nil) -> String {
        let unwrappedPeople = people?.sorted() ?? animationAssignedPeople.sorted()
        var shareString = ""
        for person in unwrappedPeople {
            shareString += person.name + " -> " + (unwrappedPeople.getPersonById(person.recipient)?.name ?? "") + "\n"
        }
        return shareString
    }

    func assignUploadAndAnimate(environment: AppEnvironment, assignedExchange: Exchange, assignedPeople: People, exchangeRepo: ExchangeRepository, peopleRepo: PeopleRepository) {

        if let currentPeople = environment.allCurrentPeople, assignedPeople.count == currentPeople.count {
            withAnimation {
                animating = true
            }

            Task {
                let _ = await exchangeRepo.put(assignedExchange)
                let _ = await peopleRepo.put(assignedPeople)
            }

            let realAnimationLength: Double = min(animationLength, Double(60.0 / Double(assignedPeople.count)))

            Timer.scheduledTimer(withTimeInterval: realAnimationLength, repeats: true) { [self] timer1 in
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
            if thisPerson.personId == thatPerson.personId
                || thisPerson.exceptions.contains(thatPerson.personId)
                || thatPerson.recipient == thisPerson.personId {
                return false
            }
            for gift in thisPerson.giftHistory {
                if thisYear - gift.year <= exchange.yearsWithoutRepeat
                    && gift.recipientId == thatPerson.personId {
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
                
                if let recipient = possibleRecipients.randomElement() {
                    var giver = person
                    giver.recipient = recipient.personId
                    
                    var needToGiveCopy = needToGive
                    var needToReceiveCopy = needToReceive
                    var assignedMembersCopy = assignedMembers
                    needToGiveCopy.removeAll(where: {$0.personId == giver.personId})
                    needToReceiveCopy.removeAll(where: {$0.personId == recipient.personId})
                    // Dear future self: this is so that the "giver's" recipient
                    // is saved in a place that canGive() can see it.
                    if needToReceiveCopy.contains(where: {$0.personId == giver.personId}) {
                        needToReceiveCopy.removeAll(where: {$0.personId == giver.personId})
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
    
    func deleteExchange(environment: AppEnvironment, exchangeId: String, exchangeRepo: ExchangeRepository, peopleRepo: PeopleRepository) {
        Task {
            let _ = await exchangeRepo.delete(exchangeId)
            let _ = await peopleRepo.delete(exchangeId)
        }
    }
    
    func endUploadAndAnimate(environment: AppEnvironment, exchange: Exchange, people: People, exchangeRepo: ExchangeRepository, peopleRepo: PeopleRepository) {
        
        withAnimation {
            animating = true
        }
        
        Task {
            let _ = await exchangeRepo.put(exchange)
            let _ = await peopleRepo.put(people)
        }
        
        Timer.scheduledTimer(withTimeInterval: animationLength / 2, repeats: true) { [self] timer in
            withAnimation(.easeInOut(duration: 0.5)) {
                animationCurrentPerson = people[currentPersonIndex]
            }
            withAnimation(.easeInOut(duration: 1)) {
                if let recipient = people.getPersonById(people[currentPersonIndex].giftHistory.first?.recipientId ?? "") {
                    animationCurrentRecipient = recipient.name
                }
            }
            
            currentPersonIndex += 1
            if currentPersonIndex >= people.count {
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
                timer.invalidate()
            }
        }.fire()
    }
    
    func endExchange(exchange: Exchange, people: People) -> (Exchange, People)? {
        if !exchange.repeating {
            showEndWarning = true
            return nil
        } else {
            var peopleWithHistory: People = []
            for person in people {
                var giver = person
                giver.giftHistory.append(
                    HistoricalGift(
                        year: exchange.year,
                        recipientId: giver.recipient,
                        description: ""))
                giver.recipient = ""
                peopleWithHistory.append(giver)
            }
            
            var exchangeWithNewDates = exchange
            exchangeWithNewDates.started = false
            if let assignDate = exchangeWithNewDates.assignDate {
                exchangeWithNewDates.assignDate = Calendar.current.date(byAdding: .year, value: 1, to: assignDate)
            }
            if let theBigDay = exchangeWithNewDates.theBigDay {
                exchangeWithNewDates.theBigDay = Calendar.current.date(byAdding: .year, value: 1, to: theBigDay)
            }
            return (exchangeWithNewDates, peopleWithHistory)
        }
    }
}
