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
                Text("Add a note that appears on your profile. You can say a little bit about yourself, explain that you really don't want anything not on your wish list, or just say hi!")
                    .multilineTextAlignment(.center)
                    .padding()
                    .transition(.opacity)
            }
            TextField("", text: $onboardingViewModel.greeting, axis: .vertical)
                .textFieldStyle(InsetTextFieldStyle(shape: RoundedRectangle(cornerRadius: 15), alignment: .leading, minHeight: 100, maxHeight: 100))
                .focused($textFieldFocused)
                .padding()
            Spacer()
        }
        .animation(.easeInOut, value: textFieldFocused)
        .onChange(of: textFieldFocused) { val in
            withAnimation(.easeInOut) {
                onboardingViewModel.smallButtons = val
            }
        }
    }
}

#Preview {
    OnboardingView(
        items: [
            OnboardGreetingView().asAnyView(),
            Text("Second View").asAnyView()
        ],
        onComplete: {},
        onCancel: {})
    .background { ShiftingBackground().ignoresSafeArea() }
    .environmentObject(AppEnvironment())
    .environmentObject(PersonOnboardingViewModel())
}
