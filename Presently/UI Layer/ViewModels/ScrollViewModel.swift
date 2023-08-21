//
//  ScrollViewModel.swift
//  Presently
//
//  Created by Thomas Patrick on 8/15/23.
//

import Foundation

class ScrollViewModel: ObservableObject {
    @Published var focusedId: String? = nil
    @Published var focusedExpanded: Bool = false
}
