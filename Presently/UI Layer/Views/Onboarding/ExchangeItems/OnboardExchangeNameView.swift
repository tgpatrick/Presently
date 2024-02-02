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
    
    @FocusState private var focusState
    
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Text("First, pick the perfect name")
                    .font(.title)
                    .bold()
                if !focusState {
                    Text("Go for something simple, but recognizable to your group. Maybe a family or team name?")
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .multilineTextAlignment(.center)
            .padding()
            if !focusState {
                Spacer()
            }
            TextField("My Perfect Name", text: $onboardingViewModel.name)
                .font(.title)
                .bold()
                .padding()
                .focused($focusState)
            Button("Done") {
                withAnimation(.easeInOut) {
                    focusState = false
                }
            }
            .buttonStyle(DepthButtonStyle())
            .padding()
            .disabled(!focusState)
            .opacity(focusState ? 1 : 0)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            Spacer()
            Spacer()
        }
        .animation(.easeInOut, value: focusState)
        .textFieldStyle(InsetTextFieldStyle(alignment: .leading))
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                focusState = false
            }
        }
        .onChange(of: onboardingViewModel.scrollPosition) { _, newValue in
            if newValue == index && onboardingViewModel.name == "" {
                withAnimation {
                    onboardingViewModel.canProceedTo = index
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
        .onChange(of: focusState) { _, newValue in
            withAnimation {
                onboardingViewModel.hideButtons = newValue
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
