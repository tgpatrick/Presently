//
//  ScrollNavItem.swift
//  Presently
//
//  Created by Thomas Patrick on 8/22/23.
//

import Foundation

struct ScrollNavItem: Identifiable {
    let id: String
    let title: String?
    let view: any NavItemView
    
    init(_ view: any NavItemView, title: String?) {
        self.id = view.id
        self.title = title
        self.view = view
    }
}
