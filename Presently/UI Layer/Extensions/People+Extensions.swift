//
//  People+Extensions.swift
//  Presently
//
//  Created by Thomas Patrick on 11/9/23.
//

import Foundation

typealias People = [Person]

extension People {
    func getPersonById(_ id: String) -> Person? {
        return self.first(where: { $0.personId == id })
    }
}
