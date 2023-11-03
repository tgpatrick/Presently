//
//  ProgressView.swift
//  Presently
//
//  Created by Thomas Patrick on 11/2/23.
//

import SwiftUI

struct OnboardingView<Content: View>: View {
    let items: [Content]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                ForEach(items.indices, id: \.self) { index in
                    items[index]
                }
            }
        }
    }
}

#Preview {
    OnboardingView(items: [
        VStack {
            Spacer()
            Text("Hello, World!")
            Spacer()
        }
    ])
    .background {
        ShiftingBackground()
            .ignoresSafeArea(.all)
    }
}
