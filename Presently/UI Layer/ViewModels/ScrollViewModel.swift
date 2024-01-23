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
    var scrollViewReader: ScrollViewProxy? = nil
    private let transitionTime = 0.3

    func focus(_ id: String) {
        withAnimation(.easeIn(duration: transitionTime)) {
            focusedId = id
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionTime) { [self] in
            withAnimation(.spring(blendDuration: transitionTime)) {
                focusedExpanded.toggle()
            }
            scrollTo(id, after: 0.2)
        }
    }
    
    func close(_ id: String) {
        withAnimation(.spring(blendDuration: transitionTime)) {
            focusedExpanded.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionTime) { [self] in
            withAnimation(.spring()) {
                focusedId = nil
            }
            scrollTo(id, after: 0.2)
        }
    }
    
    func scrollTo(_ id: String, after: Double = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            withAnimation(.spring()) {
                self.scrollViewReader?.scrollTo(id, anchor: .center)
            }
        }
    }
}
