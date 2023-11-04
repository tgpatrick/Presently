//
//  Transition+Extensions.swift
//  Presently
//
//  Created by Thomas Patrick on 11/3/23.
//

import SwiftUI

extension AnyTransition {
    static let fadeUp = AnyTransition.scale(scale: 0.9, anchor: .bottom).combined(with: .opacity)
    static let fadeDown = AnyTransition.scale(scale: 0.9, anchor: .top).combined(with: .opacity)
}
