//
//  InsetTextFieldStyle.swift
//  Presently
//
//  Created by Thomas Patrick on 8/6/23.
//

import SwiftUI

struct InsetTextFieldStyle: TextFieldStyle {
    @FocusState var focused
    var shape: AnyShape
    var alignment: TextAlignment
    var minHeight: CGFloat
    var maxHeight: CGFloat
    
    init(shape: any Shape = Capsule(), alignment: TextAlignment = .center, minHeight: CGFloat = 0, maxHeight: CGFloat = .infinity) {
        self.shape = AnyShape(shape)
        self.alignment = alignment
        self.minHeight = minHeight
        self.maxHeight = maxHeight
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        if minHeight > 0 {
            ScrollView {
                configuration
                    .focused($focused)
                    .padding(5)
            }
            .background(alignment: .topLeading, content: {
                shape
                    .fill(.shadow(.inner(radius: 2, x: 1, y: 1)))
                    .foregroundStyle(.ultraThinMaterial)
                    .padding(.horizontal, alignment == .leading ? -10 : 0)
            })
            .frame(minHeight: minHeight, maxHeight: maxHeight)
            .onTapGesture {
                withAnimation {
                    focused = true
                }
            }
        } else {
            configuration
                .multilineTextAlignment(alignment)
                .textFieldStyle(.plain)
                .padding(.vertical, 5)
                .background(alignment: .topLeading, content: {
                    shape
                        .fill(.shadow(.inner(radius: 2, x: 1, y: 1)))
                        .foregroundStyle(.ultraThinMaterial)
                        .padding(.horizontal, alignment == .leading ? -10 : 0)
                })
        }
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        TextField("Test", text: .constant(""))
            .font(.title)
            .textFieldStyle(InsetTextFieldStyle())
            .padding(.horizontal, 50)
    }
}
