//
//  GiftHistoryView.swift
//  Presently
//
//  Created by Thomas Patrick on 10/3/23.
//

import SwiftUI

struct GiftHistoryView: View {
    @EnvironmentObject var environment: AppEnvironment
    @State var fullHistory = [Int: String]()
    let user: Person
    
    var body: some View {
        VStack {
            if !user.giftHistory.isEmpty {
                if #available(iOS 17.0, *) {
                    ScrollView(.horizontal) {
                        giftHistoryItem
                            .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .padding(.horizontal, -10)
                } else {
                    ScrollView(.horizontal) {
                        giftHistoryItem
                    }
                }
            } else {
                HStack {
                    Spacer()
                    Text("(nothing here yet)")
                    Spacer()
                }
            }
        }
        .scrollIndicators(.hidden)
        .onAppear(perform: getFullHistory)
    }
    
    var giftHistoryItem: some View {
        HStack(spacing: 0) {
            ForEach(fullHistory.sorted(by: >), id: \.key) { year, description in
                VStack {
                    Text(String(year))
                        .bold()
                    Text(description)
                }
                .frame(minWidth: 200)
                .mainContentBox(material: .ultraThin)
                /*
                .contextMenu {
                    if let onTap {
                        Button("Open") {
                            onTap(gift)
                        }
                    }
                } preview: {
                    PersonPreview(id: gift.recipientId)
                        .environmentObject(environment)
                }
                 */
                .padding(.vertical, 15)
                .padding(.horizontal, 7.5)
            }
        }
        .padding(.horizontal, 10)
    }
    
    func getFullHistory() {
        guard let people = environment.allCurrentPeople else { return }
        
        for gift in user.giftHistory {
            if let recipient = people.first(where: { $0.personId == gift.recipientId }) {
                fullHistory[gift.year] = "Gave to: \(recipient.name)\n"
            }
        }
        for person in people {
            if let gift = person.giftHistory.first(where: { $0.recipientId == user.personId }) {
                if fullHistory[gift.year] == nil {
                    fullHistory[gift.year]? = ""
                }
                fullHistory[gift.year]?.append("Received from: \(person.name)")
            }
        }
    }
}

#Preview {
    let environment = AppEnvironment()
    
    return ZStack {
        ShiftingBackground()
            .ignoresSafeArea()
        ScrollView {
            GiftHistoryView(user: testPerson2)
                .padding()
                .environmentObject(environment)
                .onAppear {
                    environment.currentUser = testPerson2
                    environment.currentExchange = testExchange
                    environment.allCurrentPeople = testPeople
                }
        }
    }
}
