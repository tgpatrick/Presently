//
//  InsetTextFieldStyle.swift
//  Presently
//
//  Created by Thomas Patrick on 8/6/23.
//

import SwiftUI

struct InsetTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .multilineTextAlignment(.center)
            .textFieldStyle(.plain)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(.shadow(.inner(radius: 2, x: 1, y: 1)))
                    .foregroundStyle(.ultraThinMaterial)
            )
    }
}

struct InsetTextFieldStyle_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            TextField("Test", text: .constant(""))
                .font(.title)
                .textFieldStyle(InsetTextFieldStyle())
                .padding(.horizontal, 50)
        }
    }
}
