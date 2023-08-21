//
//  JellyScrollView.swift
//  Presently
//
//  Created by Thomas Patrick on 8/11/23.
//

import SwiftUI

struct JellyScrollView: View {
    @StateObject var viewModel = ScrollViewModel()
    @State var content: [String: any View]
    let topInset: CGFloat
    let bottomInset: CGFloat
    @State var maxHeight: CGFloat = 0
    
    var body: some View {
        ScrollViewReader { reader in
            ScrollView(showsIndicators: false) {
                VStack {
                    ContentBox(viewModel: viewModel, reader: reader, maxHeight: maxHeight, id: "1")
                        .padding()
                    ContentBox(viewModel: viewModel, reader: reader, maxHeight: maxHeight, id: "2")
                        .padding()
                    ContentBox(viewModel: viewModel, reader: reader, maxHeight: maxHeight, id: "3")
                        .padding()
                    ContentBox(viewModel: viewModel, reader: reader, maxHeight: maxHeight, id: "4")
                        .padding()
                    ContentBox(viewModel: viewModel, reader: reader, maxHeight: maxHeight, id: "5")
                        .padding()
                    ContentBox(viewModel: viewModel, reader: reader, maxHeight: maxHeight, id: "6")
                        .padding()
                }
                .padding(.top, topInset)
                .padding(.bottom, bottomInset)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                maxHeight = geo.size.height - topInset - bottomInset
                            }
                    }
                )
            }
            .scrollDisabled(viewModel.focusedId != nil)
            .padding(.top, viewModel.focusedExpanded ? topInset : 0)
            .padding(.bottom, viewModel.focusedExpanded ? bottomInset : 0)
        }
    }
}

struct ContentBox: View {
    @Namespace var namespace
    @ObservedObject var viewModel: ScrollViewModel
    var reader: ScrollViewProxy
    let maxHeight: CGFloat
    let id: String
    private let transitionTime: Double = 0.3
    
    var body: some View {
        VStack {
            if viewModel.focusedId != id || !viewModel.focusedExpanded {
                HStack {
                    Spacer()
                    Text("Test Closed!")
                    Spacer()
                }
                .matchedGeometryEffect(id: "title", in: namespace)
                Button {
                    withAnimation(.easeIn(duration: transitionTime)) {
                        viewModel.focusedId = id
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + transitionTime) {
                        withAnimation(.spring(blendDuration: transitionTime)) {
                            viewModel.focusedExpanded.toggle()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring()) {
                                reader.scrollTo(id)
                            }
                        }
                    }
                } label: {
                        Text("Open!")
                            .bold()
                            .padding(3)
                    }
                    .buttonStyle(CapsuleButtonStyle())
                    .padding()
                    .matchedGeometryEffect(id: "button", in: namespace)
            } else {
                HStack {
                    Spacer()
                    Text("Test Open!")
                    Spacer()
                }
                .matchedGeometryEffect(id: "title", in: namespace)
                Button {
                    withAnimation(.spring(blendDuration: transitionTime)) {
                        viewModel.focusedExpanded.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + transitionTime) {
                        withAnimation(.spring()) {
                            viewModel.focusedId = nil
                        }
                    }
                } label: {
                    Text("Close!")
                        .bold()
                        .padding(3)
                }
                .buttonStyle(CapsuleButtonStyle())
                .padding()
                .matchedGeometryEffect(id: "button", in: namespace)
            }
        }
        .navigationCard(id: id, viewModel: viewModel, reader: reader, maxHeight: maxHeight)
    }
}

struct JellyScrollView_Previews: PreviewProvider {
    static var previews: some View {
        JellyScrollView(content: [
            "test1" : Text("Test1")
        ],
        topInset: 0,
        bottomInset: 0)
    }
}
