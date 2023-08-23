//
//  ExchangeView.swift
//  Presently
//
//  Created by Thomas Patrick on 8/22/23.
//

import SwiftUI

struct ExchangeView: ScrollNavViewType {
    var id: String = UUID().uuidString
    var title: String? = "Your exchange"
    @Namespace var namespace: Namespace.ID
    @ObservedObject var viewModel: ScrollViewModel
    let exchange: Exchange
    
    func closedView() -> AnyView {
        ZStack {
            VStack(alignment: .leading) {
                Text(exchange.name)
                    .font(.title)
                    .bold()
                    .matchedGeometryEffect(id: "title", in: namespace)
            }
            HStack {
                Spacer()
                Image(systemName: "chevron.forward")
                    .padding()
            }
        }
        .onTapGesture {
            viewModel.focus(id)
        }
        .asAnyView()
    }

    func openView() -> AnyView {
        VStack {
            Text(exchange.name)
                .font(.title)
                .bold()
                .matchedGeometryEffect(id: "title", in: namespace)
                .modifier(NavTitleModifier())
            Spacer()
            Text("Hi, love")
            Spacer()
        }
        .asAnyView()
    }
}

struct NavTitleModifier: ViewModifier {
    @State private var originalMinX: CGFloat = 0
    @State private var swipeOffset: CGFloat = 0
    @State private var backswipeOpacity: Double = 1
    
    func body(content: Content) -> some View {
        content
            .offset(x: swipeOffset)
            .opacity(backswipeOpacity)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            originalMinX = geo.frame(in: .global).minX
                        }
                        .onChange(of: geo.frame(in: .global).minX) { newValue in
                            swipeOffset = (newValue - originalMinX) * 2
                            backswipeOpacity = max(1 - (swipeOffset * 2) / geo.size.width, 0.1)
                        }
                }
            )
    }
}

//struct ScrollItemNavBarModifier: ViewModifier {
//    @ObservedObject var viewModel: ScrollViewModel
//    var namespace: Namespace.ID
//    let viewId: String
//    let title: String? = nil
//    @State private var originalMinX: CGFloat = 0
//    @State private var swipeOffset: CGFloat = 0
//    @State private var backswipeOpacity: Double = 1
//    
//    func body(content: Content) -> some View {
//        VStack {
//            ZStack {
//                HStack {
//                    Button {
//                        viewModel.close(viewId)
//                    } label: {
//                        HStack {
//                            Image(systemName: "chevron.backward")
//                                .offset(x: swipeOffset)
//                            Text("Back")
//                                .bold()
//                                .offset(x: swipeOffset * 1.5)
//                        }
//                    }
//                    .padding(.vertical, 7.5)
//                    Spacer()
//                }
//                if let title {
//                    Text(title)
//                        .font(.title2)
//                        .bold()
//                }
//            }
//            content
//        }
//        .background(
//            GeometryReader { geo in
//                Color.clear
//                    .onAppear {
//                        originalMinX = geo.frame(in: .global).minX
//                    }
//                    .onChange(of: geo.frame(in: .global).minX) { newValue in
//                        swipeOffset = (newValue - originalMinX) * 2
//                        backswipeOpacity = max(1 - (swipeOffset * 2) / geo.size.width, 0.1)
//                    }
//            }
//        )
//    }
//}

struct ExchangeView_Previews: PreviewProvider {
    static var viewModel = ScrollViewModel()
    
    static var previews: some View {
        NavigationScrollView(viewModel: viewModel, items: [
            ExchangeView(viewModel: viewModel, exchange: testExchange)
        ])
    }
}
