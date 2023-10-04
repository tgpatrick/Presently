//
//  HistoricalGift.swift
//  GiftHub
//
//  Created by Thomas Patrick on 11/11/21.
//

import Foundation

struct HistoricalGift: Codable, Hashable {
    var year: Int
    //TODO: Add name in case someone gets removed
    var recipientId: String
    var description: String
}

extension HistoricalGift: Comparable {
    static func < (lhs: HistoricalGift, rhs: HistoricalGift) -> Bool {
        return lhs.year < rhs.year
    }
}
