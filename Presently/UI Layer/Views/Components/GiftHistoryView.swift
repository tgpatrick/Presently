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
    @State var giftToDelete: (Int, String)?
    let user: Person
    let editable: Bool
    let onEdit: ((HistoricalGift) -> Void)?
    let onDelete: ((HistoricalGift) -> Void)?
    
    init(user: Person) {
        self.user = user
        self.editable = false
        self.onEdit = nil
        self.onDelete = nil
    }
    
    init(user: Person, onEdit: @escaping (HistoricalGift) -> Void, onDelete: @escaping (HistoricalGift) -> Void) {
        self.user = user
        self.editable = true
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack {
            if !user.giftHistory.isEmpty {
                ScrollView(.horizontal) {
                    giftHistoryItem
                        .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
            } else {
                HStack {
                    Spacer()
                    Text("(nothing here yet)")
                    Spacer()
                }
                .padding(.vertical)
            }
        }
        .scrollIndicators(.hidden)
        .onAppear(perform: getFullHistory)
    }
    
    var giftHistoryItem: some View {
        HStack(spacing: 0) {
            ForEach(fullHistory.sorted(by: >), id: \.key) { year, description in
                VStack {
                    HStack {
                        Text(String(year))
                            .bold()
                        if editable && user.giftHistory.first(where: { $0.year == year }) != nil {
                            Spacer()
                            HStack {
                                Button("Delete") {
                                    if giftToDeleteMatches((year, description)) {
                                        if let onDelete { onDelete(user.giftHistory.first(where: { $0.year == year})!) }
                                    } else {
                                        withAnimation {
                                            giftToDelete = (year, description)
                                        }
                                    }
                                }
                                .buttonStyle(DepthButtonStyle(backgroundColor: .red, shadowRadius: 5))
                                Button(giftToDeleteMatches((year, description)) ? "Keep" : "Edit") {
                                    if giftToDeleteMatches((year, description)) {
                                        withAnimation {
                                            giftToDelete = nil
                                        }
                                    } else {
                                        if let onEdit { onEdit(user.giftHistory.first(where: { $0.year == year})!) }
                                    }
                                }
                                .buttonStyle(DepthButtonStyle(backgroundColor: .green, shadowRadius: 5))
                                if giftToDeleteMatches((year, description)) {
                                    Text("Are you sure?")
                                        .foregroundStyle(Color.primary)
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(Color.black)
                        }
                    }
                    Text(description)
                }
                .frame(minWidth: 200)
                .mainContentBox(material: .ultraThin)
                .fixedSize(horizontal: false, vertical: true)
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
    
    func giftToDeleteMatches(_ giftTuple: (Int, String)) -> Bool {
        if let giftToDelete, giftToDelete == giftTuple {
            return true
        }
        return false
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
            GiftHistoryView(user: testPerson2, onEdit: {_ in}, onDelete: {_ in})
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
