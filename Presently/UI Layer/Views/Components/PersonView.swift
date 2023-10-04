//
//  PersonView.swift
//  Presently
//
//  Created by Thomas Patrick on 9/25/23.
//

import SwiftUI

struct PersonView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var environment: AppEnvironment
    @EnvironmentObject var scrollViewModel: ScrollViewModel
    @State var person: Person
    var namespace: Namespace.ID
    
    var body: some View {
        TitledScrollView(title: person.name, namespace: namespace) {
            if person.organizer {
                HStack(spacing: 3) {
                    Spacer()
                    Image(systemName: "star.fill")
                        .matchedGeometryEffect(id: "star", in: namespace)
                    Text("Organizer")
                    Spacer()
                }
                .foregroundStyle(Color(colorScheme == .light ? .primaryBackground : .secondaryBackground))
                .padding(.bottom, -25)
                .offset(x: 0, y: -15)
            }
            
            if let greeting = person.greeting {
                SectionView(title: "Intro") {
                    Text(greeting)
                }
            }
            
            SectionView(title: "Wishlist") {
                if person.wishesPublic || person == environment.userAssignment {
                    WishListView(wishList: person.wishList)
                } else {
                    HStack {
                        Spacer()
                        Text("(not public)")
                        Spacer()
                    }
                }
            }
            
            if let currentExchange = environment.currentExchange,
                currentExchange.started && !currentExchange.secret,
               let recipient = environment.getPerson(id: person.recipient){
                SectionView(title: "Giving to") {
                    VStack {
                        Text(recipient.name)
                            .font(.title2)
                            .bold()
                    }
                    .padding()
                    .mainContentBox()
                    .onTapGesture {
                        withAnimation {
                            person = recipient
                        }
                    }
                    .contextMenu {
                        Button("Open") {
                            withAnimation {
                                person = recipient
                            }
                        }
                    } preview: {
                        PersonPreview(id: person.recipient)
                            .environmentObject(environment)
                    }
                    .fillHorizontally()
                }
            }
            
            SectionView(title: "History") {
                GiftHistoryView(giftHistory: person.giftHistory, onTap: { gift in
                    if let recipient = environment.getPerson(id: gift.recipientId) {
                        withAnimation {
                            person = recipient
                        }
                    }
                })
            }
        }
    }
}

struct PersonPreview: View {
    @EnvironmentObject var environment: AppEnvironment
    let id: String
    
    var body: some View {
        if let person = environment.getPerson(id: id), let exchange = environment.currentExchange {
            VStack {
                Text(person.name)
                    .font(.title2)
                    .bold()
                VStack(alignment: .leading) {
                    if exchange.started && !exchange.secret, let recipient = environment.getPerson(id: person.recipient) {
                        Text("Giving to \(recipient.name)")
                    }
                }
            }
            .padding(25)
        }
    }
}

#Preview {
    @Namespace var namespace: Namespace.ID
    
    return ZStack {
        Color(.primaryBackground).opacity(0.2)
            .ignoresSafeArea()
        PersonView(person: testPerson, namespace: namespace)
            .mainContentBox()
            .padding()
    }
    .environmentObject(AppEnvironment())
    .environmentObject(ScrollViewModel())
}
