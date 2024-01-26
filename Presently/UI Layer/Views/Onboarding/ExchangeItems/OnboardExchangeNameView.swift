//
//  OnboardExchangeNameView.swift
//  Presently
//
//  Created by Thomas Patrick on 1/24/24.
//

import SwiftUI

struct OnboardExchangeNameView: View {
    @EnvironmentObject var onboardingViewModel: ExchangeOnboardingViewModel
    
    let index: Int
    
    var body: some View {
        VStack {
            Text("First, pick the perfect name")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            TextField("Name", text: $onboardingViewModel.name)
                .font(.title)
                .padding(.horizontal)
            Spacer()
        }
        .textFieldStyle(InsetTextFieldStyle())
        .onChange(of: onboardingViewModel.scrollPosition) { _, newValue in
            if newValue == index {
                if onboardingViewModel.name == "" {
                    withAnimation {
                        onboardingViewModel.canProceedTo = index
                    }
                }
            }
        }
        .onChange(of: onboardingViewModel.name) { _, newValue in
            if newValue == "" {
                withAnimation {
                    onboardingViewModel.canProceedTo = index
                }
            } else if onboardingViewModel.canProceedTo <= index {
                withAnimation {
                    onboardingViewModel.canProceedTo = index + 1
                }
            }
        }
    }
}

#Preview {
    let environment = AppEnvironment()
    let viewModel = ExchangeOnboardingViewModel()
    
    return OnboardingView<ExchangeOnboardingViewModel>(
        items: [
            Text("First View").asAnyView(),
            OnboardExchangeNameView(index: 1).asAnyView(),
            Text("Third View").asAnyView()
        ],
        onClose: {})
    .background { ShiftingBackground().ignoresSafeArea() }
    .environmentObject(viewModel)
    .environmentObject(environment)
    .onAppear {
        viewModel.scrollPosition = 1
    }
}
