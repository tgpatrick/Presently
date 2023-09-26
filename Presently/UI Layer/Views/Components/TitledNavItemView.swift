//
//  TitledNavItemView.swift
//  Presently
//
//  Created by Thomas Patrick on 9/25/23.
//

import SwiftUI

struct TitledNavItemView<Title: View, Content: View>: View {
    let title: Title
    let content: Content
    @State private var titleHeight: CGFloat = 0
    
    init(@ViewBuilder title: () -> Title, @ViewBuilder content: () -> Content) {
        self.title = title()
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            title
                .font(.title2)
                .bold()
                .background(
                    GeometryReader { geo in
                        Color.clear.onAppear {
                            titleHeight = geo.size.height
                        }
                    }
                )
            content
                .padding(.vertical)
                .padding(.vertical, titleHeight)
        }
    }
}

#Preview {
    ZStack {
        Color(.primaryBackground).opacity(0.2).ignoresSafeArea()
        
        TitledNavItemView(title: {
            Text("This is a title")
        }, content: {
            VStack {
                Text("Hello")
                Text("This is content")
            }
        })
        .mainContentBox()
    }
}
