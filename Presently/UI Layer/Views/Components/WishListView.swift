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
        if wishList.count > 0 {
            VStack {
                ForEach(wishList, id: \.self) { wish in
                    VStack {
                        HStack {
                            Text(wish.description)
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
                                    .padding(.horizontal, 2)
                                }
                                .padding(.trailing, 7)
                            }
                        }
                        Divider()
                    }
                }
            }.buttonStyle(DepthButtonStyle(shadowRadius: 5))
        } else {
            HStack {
                Spacer()
                Text("(nothing here yet)")
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
    }
}

#Preview {
    WishListView(wishList: testPerson.wishList)
}
