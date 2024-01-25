//
//  OnboardExchangeView.swift
//  Presently
//
//  Created by Thomas Patrick on 11/12/23.
//

import SwiftUI

struct OnboardExchangeView: View {
    @EnvironmentObject var environment: AppEnvironment
    @Namespace var namespace
    
    var body: some View {
        VStack {
            Text("Your Exchange")
                .font(.title)
                .bold()
            Text("Take a second to review the information your organizer provided about your exchange.")
                .multilineTextAlignment(.center)
                .padding()
            if let currentExchange = environment.currentExchange {
                ScrollView {
                    VStack(spacing: 10) {
                        Text(currentExchange.name)
                            .font(.title2)
                            .bold()
                        SectionView(title: "Intro") {
                            Text(currentExchange.intro)
                                .accessibilityLabel("IntroText")
                        }
                        
                        SectionView(title: "Rules") {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(currentExchange.rules)
                                    .accessibilityLabel("RulesText1")
                                Text(isSecretMessage)
                                    .accessibilityLabel("RulesText2")
                                Text(isRepeatingMessage)
                                    .accessibilityLabel("RulesText3")
                            }
                        }
                        
                        SectionView(title: "Status") {
                            HStack {
                                Spacer()
                                VStack {
                                    if !currentExchange.started {
                                        Text("Open")
                                            .font(.title3)
                                            .bold()
                                        Text("Assignments have not been made and people can still be added.")
                                            .multilineTextAlignment(.center)
                                    } else {
                                        Text("Started")
                                            .font(.title3)
                                            .bold()
                                        Text("Assignments have been made. Next step is gift giving!")
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .mainContentBox()
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
                .fillHorizontally()
                .mainContentBox(padding: 0)
                .padding(.bottom)
                .padding(.bottom, 75)
            }
            Spacer()
        }
    }
    
    var isSecretMessage: String {
        guard let exchange = environment.currentExchange else { return "" }
        let firstDifference = exchange.secret ? " secret" : "n open"
        let secondDifference = exchange.secret ? "can't " : "can "
        
        return "This is a" + firstDifference + " exchange. You " + secondDifference + "see who everyone is assigned to."
    }
    
    var isRepeatingMessage: String {
        guard let exchange = environment.currentExchange else { return "" }
        let firstDifference = exchange.repeating ? "will" : "will NOT"
        
        return "This exchange " + firstDifference + " repeat."
    }
}

#Preview {
    let environment = AppEnvironment()
    return OnboardingView<PersonOnboardingViewModel>(
        items: [
            OnboardExchangeView().asAnyView(),
            OnboardGreetingView().asAnyView()
        ],
        onClose: {})
    .background { ShiftingBackground().ignoresSafeArea() }
    .environmentObject(environment)
    .environmentObject(PersonOnboardingViewModel())
    .onAppear {
        environment.currentExchange = testExchange
    }
}
