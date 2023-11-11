//
//  OnboardingView.swift
//  Presently
//
//  Created by Thomas Patrick on 11/2/23.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var environment: AppEnvironment
    @EnvironmentObject var onboardingViewModel: PersonOnboardingViewModel
    @StateObject var personRepo = PersonRepository()
    
    let buttonSize: CGFloat = 25
    let buttonPadding: CGFloat = 10
    
    let items: [AnyView]
    var onClose: () -> Void
    
    @State private var scrollPosition: Int? = 0
    @State private var movingForward: Bool = true
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack {
            if !onboardingViewModel.hideButtons {
                ZStack {
                    Text("Set Up")
                        .font(.largeTitle)
                        .bold()
                    HStack {
                        Spacer()
                        Button {
                            showAlert = true
                        } label: {
                            Image(systemName: "xmark")
                                .bold()
                        }
                    }
                    .buttonStyle(DepthButtonStyle())
                    .alert("Hang on", isPresented: $showAlert, actions: {
                        Button("Good point, I'll stay") {}
                        Button("Remind me next time") {
                            onClose()
                        }
                        Button("I'll do this later in my profile") {
                            if let currentUser = environment.currentUser {
                                Task {
                                    await onboardingViewModel.finish(personRepo: personRepo, environment: environment, person: currentUser)
                                }
                            }
                        }
                    }) {
                        Text("Filling out this information is what makes sure you get a gift you like and give to the right person!")
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            GeometryReader { geo in
                //TODO: See if ScrollView version can be patched to work on smaller phones
                if #available(iOS 17.0, *), geo.size.width > 390 {
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
                    .scrollDisabled(personRepo.isLoading || personRepo.succeeded)
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
            .padding(.bottom)
        }
    }
    
    func onboardingItem(content: AnyView, index: Int, width: CGFloat, height: CGFloat) -> some View {
        let lastIndex = items.count - 1
        return ZStack {
            items[index]
            
            if !onboardingViewModel.hideButtons {
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
                                    .frame(width: buttonSize, height: buttonSize)
                                    .padding(buttonPadding)
                            }
                            .buttonStyle(DepthButtonStyle(shape: RoundedRectangle(cornerRadius: 15)))
                            .disabled(personRepo.isLoading || personRepo.succeeded)
                        }
                        Spacer()
                        Button {
                            movingForward = true
                            if scrollPosition != nil, scrollPosition! < lastIndex {
                                withAnimation(.easeInOut) {
                                    scrollPosition! += 1
                                }
                            } else {
                                Task {
                                    await onboardingViewModel.save(personRepo: personRepo, environment: environment)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        if personRepo.succeeded {
                                            withAnimation(.easeInOut) {
                                                onClose()
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            if index == lastIndex {
                                if personRepo.isLoading {
                                    ProgressView()
                                        .frame(width: buttonSize, height: buttonSize)
                                        .padding(buttonPadding)
                                } else {
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .bold()
                                        .frame(width: buttonSize, height: buttonSize)
                                        .padding(buttonPadding)
                                }
                            } else {
                                Image(systemName: "arrow.forward")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .bold()
                                    .frame(width: buttonSize, height: buttonSize)
                                    .padding(buttonPadding)
                            }
                        }
                        .buttonStyle(DepthButtonStyle(shape: RoundedRectangle(cornerRadius: 15), backgroundColor: index != lastIndex ? Color(.accentBackground) : .green))
                    }
                    .padding()
                }
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
        onClose: {}
    )
    .background {
        ShiftingBackground()
            .ignoresSafeArea(.all)
    }
    .environmentObject(AppEnvironment())
    .environmentObject(PersonOnboardingViewModel())
}
