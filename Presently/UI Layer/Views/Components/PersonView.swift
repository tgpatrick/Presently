//
//  PersonView.swift
//  Presently
//
//  Created by Thomas Patrick on 9/25/23.
//

import SwiftUI

struct PersonView: View {
    @Environment(\.colorScheme) private var colorScheme
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
                if person.wishesPublic || viewModel.currentUser().recipient == person.id {
                    WishListView(wishList: person.wishList)
                } else {
                    HStack {
                        Spacer()
                        Text("(not public)")
                        Spacer()
                    }
                }
            }
            
            if viewModel.currentExchange().started && !viewModel.currentExchange().secret {
                SectionView(title: "Giving to") {
                    VStack {
                        Text(viewModel.getPerson(id: person.recipient).name)
                            .font(.title2)
                            .bold()
                    }
                    .padding()
                    .mainContentBox()
                    .onTapGesture {
                        withAnimation {
                            person = viewModel.getPerson(id: person.recipient)
                        }
                    }
                    .contextMenu {
                        Button("Open") {
                            withAnimation {
                                person = viewModel.getPerson(id: person.recipient)
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
                    Text(viewModel.getPerson(id: gift.recipientId).name)
                }
                .frame(minWidth: 200)
                .mainContentBox()
                .onTapGesture {
                    withAnimation {
                        person = viewModel.getPerson(id: gift.recipientId)
                    }
                }
                .contextMenu {
                    Button("Open") {
                        withAnimation {
                            person = viewModel.getPerson(id: gift.recipientId)
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
    let viewModel: ScrollViewModel
    let person: Person
    let exchange: Exchange
    @State var height: CGFloat = 0
    
    init(id: String, viewModel: ScrollViewModel) {
        self.viewModel = viewModel
        self.person = viewModel.getPerson(id: id)
        self.exchange = viewModel.currentExchange()
    }
    
    var body: some View {
        VStack {
            Text(person.name)
                .font(.title2)
                .bold()
            VStack(alignment: .leading) {
                if exchange.started && !exchange.secret {
                    Text("Giving to \(viewModel.getPerson(id: person.recipient).name)")
                }
            }
        }
        .padding(25)
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
