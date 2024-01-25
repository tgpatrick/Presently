//
//  OnboardWelcomePersonView.swift
//  Presently
//
//  Created by Thomas Patrick on 11/3/23.
//

import SwiftUI

struct OnboardWelcomePersonView: View {
    @EnvironmentObject var environment: AppEnvironment
    @EnvironmentObject var onboardingViewModel: PersonOnboardingViewModel
    
    @State private var showContent = false
    
    var body: some View {
        VStack {
            if showContent {
                Text("Welcome to Presently, " + (environment.currentUser?.name ?? "") + "!")
                    .font(.title)
                    .bold()
                    .transition(.fadeUp)
                Text("Your organizer started your account, but let's take a second to make sure everything's in order...")
                    .font(.title2)
                    .padding()
                    .transition(.fadeUp)
            }
        }
        .multilineTextAlignment(.center)
        .onAppear {
            if let currentUser = environment.currentUser, !onboardingViewModel.initialized {
                onboardingViewModel.greeting = currentUser.greeting ?? ""
                onboardingViewModel.wishList = currentUser.wishList
                onboardingViewModel.exclusions = currentUser.exceptions
                onboardingViewModel.giftHistory = currentUser.giftHistory
                onboardingViewModel.initialized = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeInOut(duration: 1)) {
                    showContent = true
                }
            }
        }
    }
}

#Preview {
    let environment = AppEnvironment()
    
    return OnboardingView<PersonOnboardingViewModel>(
        items: [
            OnboardWelcomePersonView().asAnyView(),
            Text("Second View").asAnyView()
        ],
        onClose: {})
    .background { ShiftingBackground().ignoresSafeArea() }
    .environmentObject(PersonOnboardingViewModel())
    .environmentObject(environment)
    .onAppear {
        environment.currentUser = testPerson
    }
}
