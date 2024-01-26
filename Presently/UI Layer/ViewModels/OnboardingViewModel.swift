//
//  OnboardingViewModel.swift
//  Presently
//
//  Created by Thomas Patrick on 1/24/24.
//

import Foundation

protocol OnboardingViewModel: ObservableObject {
    var scrollPosition: Int? { get set }
    var hideButtons: Bool { get set }
    var canProceedTo: Int { get set }
    
    func save(repository: any Repository, environment: AppEnvironment) async
}
