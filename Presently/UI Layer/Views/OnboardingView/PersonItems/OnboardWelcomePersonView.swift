//
//  OnboardWelcomePersonView.swift
//  Presently
//
//  Created by Thomas Patrick on 11/3/23.
//

import SwiftUI

struct OnboardWelcomePersonView: View {
    @EnvironmentObject var onboardingViewModel: PersonOnboardingViewModel
    @EnvironmentObject var environment: AppEnvironment
    @State private var showContent = false
    
    var body: some View {
        VStack {
            if showContent {
                Text("Welcome to Presently!")
                    .font(.title)
                    .bold()
                    .transition(.scale(scale: 0.9, anchor: .bottom).combined(with: .opacity))
                Text("Let's get you set up...")
                    .font(.title2)
                    .padding()
                    .transition(.scale(scale: 0.9, anchor: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            if let currentUser = environment.currentUser, !onboardingViewModel.initialized {
                onboardingViewModel.greeting = currentUser.greeting ?? ""
                onboardingViewModel.wishList = currentUser.wishList
                onboardingViewModel.giftHistory = currentUser.giftHistory
                onboardingViewModel.initialized = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 1)) {
                    showContent = true
                }
            }
        }
    }
}

#Preview {
    OnboardingView(
        items: [
            OnboardWelcomePersonView().asAnyView(),
            Text("Second View").asAnyView()
        ],
        onComplete: {},
        onCancel: {})
    .background { ShiftingBackground().ignoresSafeArea() }
    .environmentObject(PersonOnboardingViewModel())
    .environmentObject(AppEnvironment())
}
