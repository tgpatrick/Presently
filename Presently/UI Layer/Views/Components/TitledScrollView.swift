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
    let material: Material
    let content: Content
    @State private var barOpacity: Double = 0.0
    @State private var titleHeight: CGFloat = 0
    @State private var initialY: CGFloat = 0
    
    init(title: String, namespace: Namespace.ID, material: Material = .thin, @ViewBuilder content: () -> Content) {
        self.title = title
        self.namespace = namespace
        self.material = material
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .bottom) {
                Text(title)
                    .padding(.bottom, 10)
                    .modifier(NavTitleModifier(namespace: namespace))
                    .background(
                        GeometryReader { geo in
                            Color.clear.onAppear {
                                self.titleHeight = geo.size.height
                            }
                        }
                    )
                Divider()
                    .opacity(barOpacity)
                    .padding(.horizontal, -15)
            }
            .frame(maxHeight: titleHeight)
            .background(
                Rectangle()
                    .fill(material.opacity(barOpacity))
                    .padding(.horizontal, -16)
                    .padding(.top, -16)
                    .transition(.identity)
            )
            .zIndex(2)
            
            ScrollView {
                GeometryReader { geo in
                    Color.clear
                        .preference(key: ViewOffsetKey.self, value: geo.frame(in: .global).minY)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                self.initialY = geo.frame(in: .global).minY
                            }
                        }
                }
                .frame(height: 10)
                VStack(alignment: .leading, spacing: 25) {
                    content
                }
                .padding(.top, titleHeight)
            }
            .scrollIndicators(.hidden)
            .zIndex(1)
        }
        .onPreferenceChange(ViewOffsetKey.self) { value in
            let offset = initialY - value
            barOpacity = min(offset / 10, 1)
        }
    }
}

#Preview {
    @Namespace var namespace: Namespace.ID
    
    return ZStack {
        ShiftingBackground().ignoresSafeArea()
        PersonView(person: testPerson, namespace: namespace)
            .mainContentBox()
            .padding()
            .environmentObject(AppEnvironment())
            .environmentObject(ScrollViewModel())
    }
}
