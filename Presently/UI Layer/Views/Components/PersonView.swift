//
//  PersonView.swift
//  Presently
//
//  Created by Thomas Patrick on 9/25/23.
//

import SwiftUI

struct PersonView: View {
    @ObservedObject var viewModel: ScrollViewModel
    let person: Person
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
                .foregroundStyle(Color(.primaryBackground))
                .padding(.bottom, -25)
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
            
            SectionView(title: "History") {
                Group {
                    if person.giftHistory.count > 0 {
                        if #available(iOS 17.0, *) {
                            ScrollView(.horizontal) {
                                giftHistoryItem
                            }
                            .scrollTargetLayout()
                            .scrollTargetBehavior(.viewAligned)
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
                .padding(.vertical, 15)
                .padding(.horizontal, 7.5)
            }
        }
        .padding(.horizontal, 10)
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
