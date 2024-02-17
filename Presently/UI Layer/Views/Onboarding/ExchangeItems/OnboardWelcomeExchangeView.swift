//
//  OnboardWelcomeExchangeView.swift
//  Presently
//
//  Created by Thomas Patrick on 1/24/24.
//

import SwiftUI

struct OnboardWelcomeExchangeView: View {
    @EnvironmentObject var onboardingViewModel: ExchangeOnboardingViewModel
    
    let index: Int
    @State private var showContent = false
    
    var body: some View {
        VStack {
            if showContent {
                Text("Welcome to Presently!")
                    .font(.title)
                    .bold()
                    .transition(.fadeUp)
                Text("You're one step closer to a better, easier gift exchange")
                    .font(.title2)
                    .padding()
                    .transition(.fadeUp)
            }
        }
        .multilineTextAlignment(.center)
        .onAppear {
            onboardingViewModel.canProceedTo = 1
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
    
    return OnboardingView<ExchangeOnboardingViewModel, ExchangeRepository>(
        items: [
            OnboardWelcomeExchangeView(index: 0).asAnyView(),
            Text("Second View").asAnyView()
        ],
        onClose: {})
    .background { ShiftingBackground().ignoresSafeArea() }
    .environmentObject(ExchangeOnboardingViewModel())
    .environmentObject(environment)
}
