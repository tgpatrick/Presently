//
//  WishListView.swift
//  Presently
//
//  Created by Thomas Patrick on 9/25/23.
//

import SwiftUI

struct WishListView: View {
    let wishList: [WishListItem]
    
    var body: some View {
        if !wishList.isEmpty {
            VStack {
                ForEach(wishList, id: \.self) { wish in
                    VStack {
                        HStack {
                            Text(wish.description)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                            if let url = URL(string: wish.link) {
                                Link(destination: url) {
                                    HStack(spacing: 5) {
                                        Text("Link")
                                            .bold()
                                            .minimumScaleFactor(0.5)
                                        Image(.externalLink)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundStyle(.primary)
                                    }
                                    .frame(maxHeight: 15)
                                    .padding(.vertical, 5)
                                }
                                .allowsTightening(true)
                                .fixedSize()
                                .padding(.trailing, 8)
                            }
                        }
                        Divider()
                    }
                }
            }
            .buttonStyle(DepthButtonStyle(shadowRadius: 5, padding: 0))
        } else {
            HStack {
                Spacer()
                Text("(nothing here yet)")
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
                Spacer()
            }
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace: Namespace.ID
    let environment = AppEnvironment()
    
    return ZStack {
        Color(.primaryBackground).opacity(0.2)
            .ignoresSafeArea()
        PersonView(person: testPerson, namespace: namespace)
            .mainContentBox()
            .padding()
    }
    .environmentObject(ScrollViewModel())
    .environmentObject(ScrollViewModel())
    .environmentObject(environment)
    .onAppear {
        environment.currentUser = testPerson2
        environment.currentExchange = testExchange
        environment.allCurrentPeople = testPeople
    }
}
