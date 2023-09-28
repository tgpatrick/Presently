//
//  Environment.swift
//  Presently
//
//  Created by Thomas Patrick on 9/27/23.
//

import SwiftUI

class AppEnvironment: ObservableObject {
    @Published var currentUser: Person?
    @Published var currentExchange: Exchange?
    @Published var userAssignment: Person?
    @Published var allCurrentPeople: [Person]?
    
    
}
