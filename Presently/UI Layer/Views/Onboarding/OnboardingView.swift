//
//  OnboardingView.swift
//  Presently
//
//  Created by Thomas Patrick on 11/2/23.
//

import SwiftUI

struct OnboardingView<T: OnboardingViewModel>: View {
    @EnvironmentObject var environment: AppEnvironment
    @EnvironmentObject var onboardingViewModel: T
    @StateObject var personRepo = PersonRepository()
    
    let buttonSize: CGFloat = 25
    let buttonPadding: CGFloat = 10
    
    let items: [AnyView]
    var onClose: () -> Void
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
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
                .scrollPosition(id: $onboardingViewModel.scrollPosition)
                .scrollDisabled(personRepo.isLoading || personRepo.succeeded)
                .onChange(of: onboardingViewModel.scrollPosition) { _, newValue in
                    if let newValue, newValue > onboardingViewModel.canProceedTo {
                        withAnimation {
                            onboardingViewModel.scrollPosition = onboardingViewModel.canProceedTo
                        }
                    }
                }
            }
            if !onboardingViewModel.hideButtons {
                HStack {
                    ForEach(items.indices, id: \.self) { index in
                        Button {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut) {
                                    onboardingViewModel.scrollPosition = index
                                }
                            }
                        } label: {
                            Capsule()
                                .frame(width: onboardingViewModel.scrollPosition == index ? 25 : 15)
                                .animation(.easeInOut, value: onboardingViewModel.scrollPosition)
                        }
                        .foregroundStyle(onboardingViewModel.canProceedTo < index ? .gray : .accentLight)
                        .shadow(radius: 5)
                        .disabled(onboardingViewModel.canProceedTo < index)
                    }
                }
                .frame(maxHeight: 15)
                .padding(.bottom)
            } else {
                Spacer()
            }
        }
        .containerRelativeFrame(.horizontal)
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
                                if onboardingViewModel.scrollPosition != nil {
                                    withAnimation(.easeInOut) {
                                        onboardingViewModel.scrollPosition! -= 1
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
                            if onboardingViewModel.scrollPosition != nil, onboardingViewModel.scrollPosition! < lastIndex {
                                withAnimation(.easeInOut) {
                                    onboardingViewModel.scrollPosition! += 1
                                }
                            } else {
                                Task {
                                    await onboardingViewModel.save(repository: personRepo, environment: environment)
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
                        .disabled(onboardingViewModel.canProceedTo <= index)
                    }
                    .padding()
                }
            }
        }
        .mainContentBox(material: .ultraThin)
        .padding()
        .containerRelativeFrame(.horizontal)
        .blur(radius: onboardingViewModel.canProceedTo < index ? 15 : 0)
    }
}

#Preview {
    OnboardingView<PersonOnboardingViewModel>(
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
