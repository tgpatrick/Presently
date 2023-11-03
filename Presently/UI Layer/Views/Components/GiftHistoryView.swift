//
//  GiftHistoryView.swift
//  Presently
//
//  Created by Thomas Patrick on 10/3/23.
//

import SwiftUI

struct GiftHistoryView: View {
    @EnvironmentObject var environment: AppEnvironment
    @EnvironmentObject var scrollViewModel: ScrollViewModel
    let giftHistory: [HistoricalGift]
    var onTap: ((HistoricalGift) -> Void)? = nil
    
    var body: some View {
        Group {
            if !giftHistory.isEmpty {
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
    }
    
    var giftHistoryItem: some View {
        HStack(spacing: 0) {
            ForEach(giftHistory, id: \.self) { gift in
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
                    if let onTap {
                        onTap(gift)
                    }
                }
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
                .padding(.vertical, 15)
                .padding(.horizontal, 7.5)
            }
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    GiftHistoryView(giftHistory: testPerson.giftHistory)
        .environmentObject(AppEnvironment())
        .environmentObject(ScrollViewModel())
}
