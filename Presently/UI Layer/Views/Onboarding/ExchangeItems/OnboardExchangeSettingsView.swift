//
//  OnboardExchangeSettingsView.swift
//  Presently
//
//  Created by Thomas Patrick on 1/29/24.
//

import SwiftUI

struct OnboardExchangeSettingsView: View {
    @EnvironmentObject var onboardingViewModel: ExchangeOnboardingViewModel
    
    let index: Int
    
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Text("Check some basic settings")
                    .font(.title)
                    .bold()
                Text("Most exchanges will be good with the defaults, but maybe you're special!")
            }
            .multilineTextAlignment(.center)
            .padding()
            ScrollView {
                VStack(alignment: .leading) {
                    Toggle("Secret", isOn: $onboardingViewModel.secret)
                        .font(.title3)
                        .bold()
                    Text("Makes assignments private, so everyone will see only their own assignment. Perfect for Secret Santa!")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, -10)
                    
                    Toggle("Repeating", isOn: $onboardingViewModel.repeating)
                        .font(.title3)
                        .bold()
                    Text("After gifting, automatically resets the exchange to go again next year. Turn off to self destruct instead.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, -10)
                    
                    Stepper("Gift interval: \(onboardingViewModel.yearsWithoutRepeat)", value: $onboardingViewModel.yearsWithoutRepeat, in: 0...15)
                        .font(.title3)
                        .bold()
                    Text("How many years need to pass before someone could possibly give to the same person again?")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, -10)
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
            .safeAreaPadding(.bottom, 100)
            Spacer()
        }
        .onChange(of: onboardingViewModel.scrollPosition) { _, newValue in
            if newValue == index {
                if onboardingViewModel.canProceedTo < index + 1 {
                    withAnimation {
                        onboardingViewModel.canProceedTo = index + 1
                    }
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
            OnboardExchangeSettingsView(index: 1).asAnyView(),
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
