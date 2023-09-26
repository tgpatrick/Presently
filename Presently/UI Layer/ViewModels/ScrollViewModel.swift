//
//  ScrollViewModel.swift
//  Presently
//
//  Created by Thomas Patrick on 8/15/23.
//

import SwiftUI

class ScrollViewModel: ObservableObject {
    @AppStorage("CurrentExchangeID") var exchangeID: String?
    @AppStorage("CurrentPersonID") var personID: String?
    
    @Published var focusedId: String? = nil
    @Published var focusedExpanded: Bool = false
    var scrollViewReader: ScrollViewProxy? = nil
    private let transitionTime = 0.3
    
    func currentUser() -> Person {
        testPerson
    }
    
    func assignedPerson() -> Person {
        testPeople.first(where: {$0.personId == currentUser().recipient}) ?? testPerson
    }
    
    func getPerson(id: String) -> Person {
        testPeople.first(where: {$0.personId == id}) ?? testPerson
    }
    
    func currentExchange() -> Exchange {
        testExchange
    }
    
    func currentPeople() -> [Person] {
        testPeople
    }

    func focus(_ id: String) {
        withAnimation(.easeIn(duration: transitionTime)) {
            focusedId = id
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionTime) { [self] in
            withAnimation(.spring(blendDuration: transitionTime)) {
                focusedExpanded.toggle()
            }
            scrollTo(id, after: 0.2)
        }
    }
    
    func close(_ id: String) {
        withAnimation(.spring(blendDuration: transitionTime)) {
            focusedExpanded.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionTime) { [self] in
            withAnimation(.spring()) {
                focusedId = nil
            }
            scrollTo(id, after: 0.15)
        }
    }
    
    func scrollTo(_ id: String, after: Double = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            withAnimation(.spring()) {
                self.scrollViewReader?.scrollTo(id)
            }
        }
    }
}
