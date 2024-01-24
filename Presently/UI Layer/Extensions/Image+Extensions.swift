//
//  Image+Extensions.swift
//  Presently
//
//  Created by Thomas Patrick on 1/23/24.
//

import SwiftUI

extension Image {
    func tabBarImage() -> some View {
        self
            .resizable()
            .fontWeight(.light)
            .aspectRatio(contentMode: .fit)
            .frame(height: 30)
    }
}
