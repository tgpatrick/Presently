//
//  OnboardGreetingView.swift
//  Presently
//
//  Created by Thomas Patrick on 11/3/23.
//

import SwiftUI

struct OnboardGreetingView: View {
    @EnvironmentObject var environment: AppEnvironment
    @EnvironmentObject var onboardingViewModel: PersonOnboardingViewModel
    @FocusState var textFieldFocused
    
    var body: some View {
        VStack {
            Text("Write a Greeting")
                .font(.title)
                .bold()
            if !textFieldFocused {
                Text("Add a note that appears on your profile. Say a little about yourself, explain that you're excited to receive something from your very specific wish list, or just say hi!")
                    .multilineTextAlignment(.center)
                    .padding()
                    .transition(.opacity)
            }
            TextField("", text: $onboardingViewModel.greeting, axis: .vertical)
                .textFieldStyle(InsetTextFieldStyle(shape: RoundedRectangle(cornerRadius: 15), alignment: .leading, minHeight: 100))
                .focused($textFieldFocused)
                .padding()
                .padding(.bottom, onboardingViewModel.hideButtons ? 0 : 75)
            Spacer()
            if textFieldFocused {
                Button("Done") {
                    textFieldFocused = false
                }
                .buttonStyle(DepthButtonStyle())
                .padding(.bottom)
            }
        }
        .animation(.easeInOut, value: textFieldFocused)
        .onChange(of: textFieldFocused) { _, val in
            withAnimation(.easeInOut) {
                onboardingViewModel.hideButtons = val
            }
        }
    }
}

#Preview {
    OnboardingView<PersonOnboardingViewModel, PersonRepository>(
        items: [
            OnboardGreetingView().asAnyView(),
            OnboardWishListView().asAnyView()
        ],
        onClose: {})
    .background { ShiftingBackground().ignoresSafeArea() }
    .environmentObject(AppEnvironment())
    .environmentObject(PersonOnboardingViewModel())
}
