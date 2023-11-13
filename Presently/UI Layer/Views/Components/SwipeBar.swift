//
//  SwipeBar.swift
//  Presently
//
//  Created by Thomas Patrick on 11/6/23.
//

import SwiftUI

struct SwipeBar: View {
    var description: String? = nil
    var onChanged: ((Double) -> Void)? = nil
    let action: () -> Bool
    
    private let maxHeight: CGFloat = 75
    private let depth: CGFloat = 5
    @State private var swipeOffset: CGFloat = .zero
    @State private var circleDiameter: CGFloat = .zero
    @State private var barWidth: CGFloat = .zero
    @State private var circleMaxX: CGFloat = .zero

    var body: some View {
        ZStack(alignment: .leading) {
            ZStack {
                Capsule()
                    .fill(.shadow(.inner(radius: 3, x: 2, y: 2)))
                    .foregroundStyle(.ultraThinMaterial)
                    .background {
                        GeometryReader { geo in
                            Color(.accentBackground).opacity(0.25)
                                .onAppear {
                                    barWidth = geo.size.width - depth * 2
                                }
                        }
                    }
                    .background {
                        Color(.accentBackground)
                            .opacity((swipeOffset / barWidth + 0.4))
                            .offset(CGSize(width: (-1 * barWidth) + swipeOffset, height: 0))
                    }
                if let description {
                    HStack {
                        Text(description)
                            .multilineTextAlignment(.center)
                            .opacity(0.5)
                            .bold()
                            .blur(radius: 10 * (swipeOffset / barWidth))
                            .offset(CGSize(width: swipeOffset / 1.5, height: 0))
                    }
                    .padding(.leading, circleDiameter)
                    .padding(.trailing, depth)
                }
            }
            .frame(maxHeight: maxHeight)
            .clipShape(Capsule())
            ZStack {
                Circle()
                    .fill(.shadow(.inner(radius: 5)))
                    .foregroundStyle(Color(.accentBackground))
                    .background(
                        GeometryReader { geo in
                            Color.clear.opacity(0.8).onAppear {
                                circleDiameter = geo.size.width
                                circleMaxX = geo.frame(in: .global).maxX
                            }
                        }
                    )
                Image(systemName: "arrow.forward")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.9)
                    .padding(20)
                    .fontWeight(.heavy)
            }
            .frame(maxHeight: maxHeight - depth * 2)
            .overlay {
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color.white.opacity(0.25),
                            Color.clear
                        ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .clipShape(Circle())
            .shadow(radius: depth, x: 2, y: 2)
            .padding(depth)
            .offset(CGSize(width: swipeOffset, height: 0))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.25)) {
                    swipeOffset = 20
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        swipeOffset = 0
                    }
                }
            }
            .highPriorityGesture(
                DragGesture(coordinateSpace: .local)
                    .onChanged { currentState in
                        if currentState.translation.width > 0 && currentState.translation.width < (barWidth - circleDiameter) {
                            withAnimation(.interactiveSpring) {
                                swipeOffset = currentState.translation.width
                            }
                            if let onChanged { onChanged(swipeOffset / barWidth) }
                        }
                    }
                    .onEnded { endState in
                        if endState.translation.width >= (barWidth - circleDiameter) {
                            if !action() {
                                reset()
                            }
                        } else {
                            reset()
                        }
                    }
            )
        }
    }
    
    func reset() {
        withAnimation(.snappy) {
            swipeOffset = 0
        }
        if let onChanged { onChanged(0) }
    }
}

#Preview {
    ZStack {
        ShiftingBackground()
        SwipeBar(description: "Swipe to do a thing", action: { false })
            .padding()
    }
}
