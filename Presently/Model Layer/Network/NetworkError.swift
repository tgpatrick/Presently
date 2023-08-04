//
//  NetworkError.swift
//  Presently
//
//  Created by Thomas Patrick on 8/2/23.
//

import Foundation

enum NetworkError: Error {
    case unknown(Error, url: String)
    case serverError(code: Int, url: String)
    case decoding(Error, url: String)
    case request
}
