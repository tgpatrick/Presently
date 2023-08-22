//
//  ScrollViewModel.swift
//  Presently
//
//  Created by Thomas Patrick on 8/15/23.
//

import SwiftUI

class ScrollViewModel: ObservableObject {
    @Published var focusedId: String? = nil
    @Published var focusedExpanded: Bool = false
    private let transitionTime = 0.3
    
    func focus(_ id: String, reader: ScrollViewProxy) {
        withAnimation(.easeIn(duration: transitionTime)) {
            focusedId = id
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionTime) { [self] in
            withAnimation(.spring(blendDuration: transitionTime)) {
                focusedExpanded.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring()) {
                    reader.scrollTo(id)
                }
            }
        }
    }
    
    func close(_ id: String, reader: ScrollViewProxy) {
        withAnimation(.spring(blendDuration: transitionTime)) {
            focusedExpanded.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionTime) { [self] in
            withAnimation(.spring()) {
                focusedId = nil
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring()) {
                    reader.scrollTo(id)
                }
            }
        }
    }
}
