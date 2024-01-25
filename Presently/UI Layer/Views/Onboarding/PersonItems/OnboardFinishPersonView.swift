//
//  OnboardFinishPersonView.swift
//  Presently
//
//  Created by Thomas Patrick on 11/3/23.
//

import SwiftUI

struct OnboardFinishPersonView: View {
    @EnvironmentObject var environment: AppEnvironment
    @EnvironmentObject var onboardingViewModel: PersonOnboardingViewModel
    
    @State private var showContent = false
    
    var body: some View {
        VStack {
            if showContent {
                Text("You're all set, " + (environment.currentUser?.name ?? "") + "!")
                    .font(.title)
                    .bold()
                    .transition(.fadeUp)
                    .padding()
                Text("Don't forget, you can change any of this later from your profile.")
                .font(.title2)
                    .transition(.fadeUp)
            }
        }
        .multilineTextAlignment(.center)
        .onAppear {
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
            OnboardFinishPersonView().asAnyView()
        ],
        onClose: {})
    .background { ShiftingBackground().ignoresSafeArea() }
    .environmentObject(environment)
    .environmentObject(PersonOnboardingViewModel())
    .onAppear {
        environment.currentUser = testPerson
    }
}
