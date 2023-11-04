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
                    .transition(.scale(scale: 0.9, anchor: .bottom).combined(with: .opacity))
                    .padding()
                Text("Don't forget, you can change any of this later from your profile.")
                    .transition(.scale(scale: 0.9, anchor: .bottom).combined(with: .opacity))
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
    
    return OnboardingView(
        items: [
            OnboardFinishPersonView().asAnyView()
        ],
        onComplete: {},
        onCancel: {})
    .background { ShiftingBackground().ignoresSafeArea() }
    .environmentObject(environment)
    .environmentObject(PersonOnboardingViewModel())
    .onAppear {
        environment.currentUser = testPerson
    }
}
