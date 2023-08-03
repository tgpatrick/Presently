//
//  Response.swift
//  GiftHub
//
//  Created by Thomas Patrick on 11/11/21.
//

import Foundation

struct ItemResponse<T: Decodable>: Decodable {
    var Item: T
}

struct MultipleItemResponse<T: Decodable>: Decodable {
    var Items: [T]
}

struct UnusedReponse: Codable { }
