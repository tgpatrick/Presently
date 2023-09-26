//
//  SectionComponentView.swift
//  Presently
//
//  Created by Thomas Patrick on 9/25/23.
//

import SwiftUI

struct SectionView<Content>: View where Content: View {
    let title: String
    var content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .navCardSectionTitle()
            content
        }
    }
}

#Preview {
    ZStack {
        Color(.primaryBackground).opacity(0.2).ignoresSafeArea()
        VStack {
            SectionView(title: "Test") {
                Text("Hello, World!")
            }
        }
        .mainContentBox()
        .padding()
    }
}
