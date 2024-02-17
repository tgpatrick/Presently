//
//  OnboardIntroAndRulesView.swift
//  Presently
//
//  Created by Thomas Patrick on 1/29/24.
//

import SwiftUI

struct OnboardIntroAndRulesView: View {
    @EnvironmentObject var onboardingViewModel: ExchangeOnboardingViewModel
    
    let index: Int
    
    enum IntroRulesField: Hashable {
        case intro
        case rules
    }
    @FocusState private var focusState: IntroRulesField?
    
    @FocusState var textFieldFocused
    
    
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Text("Next, set your introduction and rules")
                    .font(.title)
                    .bold()
                if focusState == nil {
                    Text("Say hello or describe your exchange, then set the rules. Is there a price limit? A theme? Let your members know!")
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .multilineTextAlignment(.center)
            .padding()
            ScrollView {
                VStack {
                    if focusState != .rules {
                        VStack(alignment: .leading) {
                            Text("Introduction")
                                .bold()
                            TextField("Welcome to my exchange!", text: $onboardingViewModel.intro, axis: .vertical)
                                .textFieldStyle(InsetTextFieldStyle(shape: RoundedRectangle(cornerRadius: 15), alignment: .leading, minHeight: 100))
                                .focused($focusState, equals: .intro)
                        }
                        .padding(.horizontal)
                    }
                    if focusState != .intro {
                        VStack(alignment: .leading) {
                            Text("Rules")
                                .bold()
                            TextField("You're allowed to spend...", text: $onboardingViewModel.rules, axis: .vertical)
                                .textFieldStyle(InsetTextFieldStyle(shape: RoundedRectangle(cornerRadius: 15), alignment: .leading, minHeight: 100))
                                .focused($focusState, equals: .rules)
                        }
                        .padding(.horizontal)
                    }
                    if focusState != nil {
                        Button("Done") {
                            withAnimation(.easeInOut) {
                                focusState = nil
                            }
                        }
                        .buttonStyle(DepthButtonStyle())
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .transition(.opacity)
            .safeAreaPadding(.bottom, 75)
            Spacer()
        }
        .animation(.easeInOut, value: focusState)
        .onChange(of: onboardingViewModel.scrollPosition) { _, newValue in
            if newValue == index {
                if onboardingViewModel.canProceedTo < index + 1 {
                    withAnimation {
                        onboardingViewModel.canProceedTo = index + 1
                    }
                }
            }
        }
        .onChange(of: focusState) { _, newValue in
            onboardingViewModel.hideButtons = newValue != nil
        }
    }
}

#Preview {
    let environment = AppEnvironment()
    let viewModel = ExchangeOnboardingViewModel()
    
    return OnboardingView<ExchangeOnboardingViewModel, ExchangeRepository>(
        items: [
            Text("First View").asAnyView(),
            OnboardIntroAndRulesView(index: 1).asAnyView(),
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
