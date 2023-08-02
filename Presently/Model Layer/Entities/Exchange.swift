//
//  Exchange.swift
//  GiftHub
//
//  Created by Thomas Patrick on 11/11/21.
//

import Foundation

struct Exchange: Hashable, Codable, Equatable {
    var id: String
    var name: String
    var year: Int
    var secret: Bool
    var repeating: Bool
    var started: Bool
    var yearsWithoutRepeat: Int
}
