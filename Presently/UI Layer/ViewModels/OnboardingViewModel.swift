//
//  OnboardingViewModel.swift
//  Presently
//
//  Created by Thomas Patrick on 1/24/24.
//

import Foundation

protocol OnboardingViewModel: ObservableObject {
    var hideButtons: Bool { get set }
    
    func save(repository: any Repository, environment: AppEnvironment) async
}
