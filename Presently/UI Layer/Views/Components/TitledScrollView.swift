//
//  TitledScrollView.swift
//  Presently
//
//  Created by Thomas Patrick on 9/25/23.
//

import SwiftUI

struct TitledScrollView<Content>: View where Content: View {
    let title: String
    var namespace: Namespace.ID
    var customMatchTitle: String?
    let material: Material
    let content: Content
    @State private var safeToScroll: Bool = false
    @State private var barOpacity: Double = 0.0
    @State private var titleHeight: CGFloat = 0
    @State private var initialY: CGFloat = 0
    
    init(title: String, namespace: Namespace.ID, customMatchTitle: String? = nil, material: Material = .thin, @ViewBuilder content: () -> Content) {
        self.title = title
        self.namespace = namespace
        self.customMatchTitle = customMatchTitle
        self.material = material
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            GeometryReader { geo in
                Color.clear
                    .preference(key: ViewOffsetKey.self, value: geo.frame(in: .global).minY)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                            self.initialY = geo.frame(in: .global).minY
                            safeToScroll = true
                        }
                    }
            }
            .frame(height: 10)
            VStack(alignment: .leading, spacing: 25) {
                content
            }
        }
        .scrollIndicators(.hidden)
        .scrollDisabled(!safeToScroll)
        .safeAreaInset(edge: .top) {
            ZStack(alignment: .bottom) {
                Text(title)
                    .padding(.bottom, 10)
                    .modifier(NavTitleModifier(namespace: namespace, customMatchTitle: customMatchTitle))
                    .background(
                        GeometryReader { geo in
                            Color.clear.onAppear {
                                self.titleHeight = geo.size.height
                            }
                        }
                    )
                Divider()
                    .opacity(barOpacity)
                    .ignoresSafeArea()
            }
            .frame(maxHeight: titleHeight)
            .background(
                Rectangle()
                    .fill(material.opacity(barOpacity))
                    .ignoresSafeArea()
                    .transition(.identity)
            )
        }
        .onPreferenceChange(ViewOffsetKey.self) { value in
            let offset = initialY - value
            barOpacity = min(offset / 10, 1)
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace: Namespace.ID
    
    return ZStack {
        ShiftingBackground().ignoresSafeArea()
        PersonView(person: testPerson, namespace: namespace)
            .mainContentBox()
            .padding()
            .environmentObject(AppEnvironment())
            .environmentObject(ScrollViewModel())
    }
}
