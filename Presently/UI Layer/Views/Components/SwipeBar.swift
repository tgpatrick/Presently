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
    let action: () -> Void
    
    private let maxHeight: CGFloat = 75
    private let depth: CGFloat = 5
    @State private var swipeOffset: CGFloat = .zero
    @State private var circleDiameter: CGFloat = .zero
    @State private var barWidth: CGFloat = .zero
    @State private var circleMaxX: CGFloat = .zero
    @State private var descriptionMinX: CGFloat = .zero

    var body: some View {
        ZStack(alignment: .leading) {
            ZStack {
                Capsule()
                    .fill(.shadow(.inner(radius: 3, x: 2, y: 2)))
                    .foregroundStyle(.ultraThinMaterial)
                    .background {
                        GeometryReader { geo in
                            Color(.accentBackground).opacity(swipeOffset / barWidth + 0.3)
                                .onAppear {
                                    barWidth = geo.size.width - depth * 2
                                }
                        }
                    }
                if let description {
                    Text(description)
                        .opacity(0.5)
                        .bold()
                        .blur(radius: 10 * (swipeOffset / barWidth))
                        .padding(.leading, descriptionMinX > circleMaxX ? 0 : circleDiameter)
                        .background {
                            GeometryReader { geo in
                                Color.clear.onAppear {
                                    descriptionMinX = geo.frame(in: .global).minX
                                }
                            }
                        }
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
                    .opacity(0.8)
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
            .offset(CGSize(width: swipeOffset, height: 0.0))
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
                        if endState.translation.width < (barWidth - circleDiameter) {
                            withAnimation(.snappy) {
                                swipeOffset = 0
                            }
                            if let onChanged { onChanged(0) }
                        } else {
                            action()
                        }
                    }
            )
        }
    }
}

#Preview {
    ZStack {
        ShiftingBackground()
        SwipeBar(description: "Swipe to do a thing", action: {})
            .padding()
    }
}
