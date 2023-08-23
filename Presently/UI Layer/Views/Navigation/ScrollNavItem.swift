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
    let view: any ScrollNavViewType
    
    init(_ view: any ScrollNavViewType, title: String?) {
        self.id = view.id
        self.title = title
        self.view = view
    }
}
