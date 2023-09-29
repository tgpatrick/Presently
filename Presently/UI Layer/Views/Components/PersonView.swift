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
    @ObservedObject var viewModel: ScrollViewModel
    @State var person: Person
    var namespace: Namespace.ID
    
    var body: some View {
        TitledScrollView(title: person.name, namespace: namespace) {
            if person.organizer {
                HStack(spacing: 3) {
                    Spacer()
                    Image(systemName: "star.fill")
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
                        PersonPreview(id: person.recipient, viewModel: viewModel)
                    }
                    .fillHorizontally()
                }
            }
            
            SectionView(title: "History") {
                Group {
                    if person.giftHistory.count > 0 {
                        if #available(iOS 17.0, *) {
                            ScrollView(.horizontal) {
                                giftHistoryItem
                            }
                            .scrollTargetLayout()
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
            }
        }
    }
    
    var giftHistoryItem: some View {
        HStack(spacing: 0) {
            ForEach(person.giftHistory, id: \.self) { gift in
                VStack {
                    Text(String(gift.year))
                        .bold()
                    if let recipient = environment.getPerson(id: gift.recipientId) {
                        Text(recipient.name)
                    }
                }
                .frame(minWidth: 200)
                .mainContentBox()
                .onTapGesture {
                    if let recipient = environment.getPerson(id: gift.recipientId) {
                        withAnimation {
                            person = recipient
                        }
                    }
                }
                .contextMenu {
                    if let recipient = environment.getPerson(id: gift.recipientId) {
                        Button("Open") {
                            withAnimation {
                                person = recipient
                            }
                        }
                    }
                } preview: {
                    PersonPreview(id: gift.recipientId, viewModel: viewModel)
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 7.5)
            }
        }
        .padding(.horizontal, 10)
    }
}

struct PersonPreview: View {
    @EnvironmentObject var environment: AppEnvironment
    let id: String
    let viewModel: ScrollViewModel
    
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
    var viewModel = ScrollViewModel()
    @Namespace var namespace: Namespace.ID
    
    return ZStack {
        Color(.primaryBackground).opacity(0.2)
            .ignoresSafeArea()
        PersonView(viewModel: viewModel, person: testPerson, namespace: namespace)
            .mainContentBox()
            .padding()
    }
}
