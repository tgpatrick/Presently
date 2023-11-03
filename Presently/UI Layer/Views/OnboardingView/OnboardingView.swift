//
//  OnboardingView.swift
//  Presently
//
//  Created by Thomas Patrick on 11/2/23.
//

import SwiftUI

struct OnboardingView: View {
    let items: [AnyView]
    var onComplete: () -> Void
    var onCancel: () -> Void
    
    @State private var scrollPosition: Int? = 0
    @State private var movingForward: Bool = true
    
    var body: some View {
        VStack {
            ZStack {
                Text("Set Up")
                    .font(.largeTitle)
                    .bold()
                HStack {
                    Spacer()
                    Button {
                        onCancel()
                    } label: {
                        Image(systemName: "xmark")
                            .bold()
                    }
                }
                .buttonStyle(DepthButtonStyle())
            }
            .padding(.horizontal)
            .padding(.top)
            GeometryReader { geo in
                if #available(iOS 17.0, *) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(items.indices, id: \.self) { index in
                                onboardingItem(
                                    content: items[index],
                                    index: index,
                                    width: geo.size.width,
                                    height: geo.size.height
                                )
                                .scrollTransition { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0)
                                        .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                        .blur(radius: phase.isIdentity ? 0 : 10)
                                }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $scrollPosition)
                } else {
                    onboardingItem(
                        content: items[scrollPosition ?? 0],
                        index: scrollPosition ?? 0,
                        width: geo.size.width,
                        height: geo.size.height
                    )
                    .id(scrollPosition)
                    .transition(movingForward ?
                        .asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ) :
                            .asymmetric(
                                insertion: .move(edge: .leading),
                                removal: .move(edge: .trailing)
                            )
                    )
                }
            }
            HStack {
                ForEach(items.indices, id: \.self) { index in
                    Button {
                        if let scrollPosition {
                            movingForward = index > scrollPosition
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut) {
                                scrollPosition = index
                            }
                        }
                    } label: {
                        Capsule()
                            .frame(width: scrollPosition == index ? 25 : 15)
                            .animation(.easeInOut, value: scrollPosition)
                    }
                    .foregroundStyle(Color(.accentLight))
                    .shadow(radius: 5)
                }
            }
            .frame(maxHeight: 15)
        }
    }
    
    func onboardingItem(content: AnyView, index: Int, width: CGFloat, height: CGFloat) -> some View {
        let lastIndex = items.count - 1
        return ZStack {
            items[index]
            Spacer()
            VStack {
                Spacer()
                HStack {
                    if items.count > 0 && index != 0 {
                        Button {
                            movingForward = false
                            if scrollPosition != nil {
                                withAnimation(.easeInOut) {
                                    scrollPosition! -= 1
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.backward")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .bold()
                                .frame(width: 25, height: 25)
                                .padding(10)
                        }
                        .buttonStyle(DepthButtonStyle(shape: RoundedRectangle(cornerRadius: 15)))
                    }
                    Spacer()
                    Button {
                        movingForward = true
                        if scrollPosition != nil, scrollPosition! < lastIndex {
                            withAnimation(.easeInOut) {
                                scrollPosition! += 1
                            }
                        } else {
                            withAnimation(.easeInOut) {
                                onComplete()
                            }
                        }
                    } label: {
                        Image(systemName: index == lastIndex ? "checkmark" : "arrow.forward")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .bold()
                            .frame(width: 25, height: 25)
                            .padding(10)
                    }
                    .buttonStyle(DepthButtonStyle(shape: RoundedRectangle(cornerRadius: 15), backgroundColor: index != lastIndex ? Color(.accentBackground) : .green))
                }
                .padding()
            }
        }
        .fillHorizontally()
        .mainContentBox(material: .ultraThin)
        .padding()
        .frame(idealWidth: width, idealHeight: height)
    }
}

#Preview {
    OnboardingView(
        items: [
            ScrollView {
                Text("Hello, World 1!")
            }.asAnyView(),
            VStack {
                Text("Hello, World 2!")
            }.asAnyView(),
            VStack {
                Text("Hello, World 3!")
            }.asAnyView()
        ],
        onComplete: {},
        onCancel: {}
    )
    .background {
        ShiftingBackground()
            .ignoresSafeArea(.all)
    }
}
