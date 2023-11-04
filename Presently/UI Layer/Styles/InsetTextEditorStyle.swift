//
//  InsetTextEditorStyle.swift
//  Presently
//
//  Created by Thomas Patrick on 11/3/23.
//

import SwiftUI

//struct InsetTextEditorStyle: TextEditorStyle {
//    var shape: AnyShape
//    var alignment: TextAlignment
//    
//    init(shape: any Shape = Capsule(), alignment: TextAlignment = .center) {
//        self.shape = AnyShape(shape)
//        self.alignment = alignment
//    }
//    
//    func _body(configuration: Self.Configuration) -> some View {
//        configuration
//            .multilineTextAlignment(alignment)
//            .textFieldStyle(.plain)
//            .padding(.vertical, 5)
//            .background(
//                shape
//                    .fill(.shadow(.inner(radius: 2, x: 1, y: 1)))
//                    .foregroundStyle(.ultraThinMaterial)
//                    .padding(.horizontal, alignment == .leading ? -10 : 0)
//            )
//    }
//}

//#Preview {
//    ZStack {
//        Color.gray.ignoresSafeArea()
//        TextField("Test", text: .constant(""))
//            .font(.title)
//            .textFieldStyle(InsetTextFieldStyle())
//            .padding(.horizontal, 50)
//    }
//}
