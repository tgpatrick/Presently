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
                Spacer().frame(height: topInset)
                ContentBox(viewModel: viewModel, reader: reader, maxHeight: maxHeight, id: "1")
                    .navigationCard(id: "1", viewModel: viewModel, reader: reader, maxHeight: maxHeight, topInset: topInset, bottomInset: bottomInset, scrollReader: reader)
                    .padding()
                ContentBox(viewModel: viewModel, reader: reader, maxHeight: maxHeight, id: "2")
                    .navigationCard(id: "2", viewModel: viewModel, reader: reader, maxHeight: maxHeight, topInset: topInset, bottomInset: bottomInset, scrollReader: reader)
                    .padding()
                ContentBox(viewModel: viewModel, reader: reader, maxHeight: maxHeight, id: "3")
                    .navigationCard(id: "3", viewModel: viewModel, reader: reader, maxHeight: maxHeight, topInset: topInset, bottomInset: bottomInset, scrollReader: reader)
                    .padding()
                ContentBox(viewModel: viewModel, reader: reader, maxHeight: maxHeight, id: "4")
                    .navigationCard(id: "4", viewModel: viewModel, reader: reader, maxHeight: maxHeight, topInset: topInset, bottomInset: bottomInset, scrollReader: reader)
                    .padding()
                ContentBox(viewModel: viewModel, reader: reader, maxHeight: maxHeight, id: "5")
                    .navigationCard(id: "5", viewModel: viewModel, reader: reader, maxHeight: maxHeight, topInset: topInset, bottomInset: bottomInset, scrollReader: reader)
                    .padding()
                ContentBox(viewModel: viewModel, reader: reader, maxHeight: maxHeight, id: "6")
                    .navigationCard(id: "6", viewModel: viewModel, reader: reader, maxHeight: maxHeight, topInset: topInset, bottomInset: bottomInset, scrollReader: reader)
                    .padding()
                Spacer().frame(height: bottomInset)
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            maxHeight = geo.size.height - topInset - bottomInset - 20
                        }
                }
            )
            .scrollDisabled(viewModel.focusedId != nil)
            .padding(.bottom, (viewModel.focusedId != nil && viewModel.focusedExpanded) ? bottomInset : 0)
        }
    }
}

struct ContentBox: View {
    @Namespace var namespace
    @ObservedObject var viewModel: ScrollViewModel
    var reader: ScrollViewProxy
    let maxHeight: CGFloat
    let id: String
    
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
                    viewModel.focus(id, reader: reader)
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
            }
        }
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
