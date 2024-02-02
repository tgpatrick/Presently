//
//  OnboardDatesView.swift
//  Presently
//
//  Created by Thomas Patrick on 1/29/24.
//

import SwiftUI

struct OnboardDatesView: View {
    @EnvironmentObject var onboardingViewModel: ExchangeOnboardingViewModel
    @Namespace var namespace
    let index: Int
    
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Text("Next, set the important dates.")
                    .font(.title)
                    .bold()
                Text("Let your group know when you'll make the assignments and the big day. Don't worry, you'll be able to change this later if you need to!")
            }
            .multilineTextAlignment(.center)
            .padding()
            
            VStack(spacing: 25) {
                if onboardingViewModel.assignDate == nil {
                    HStack {
                        Text("Assignment Date")
                        Spacer()
                        Button("Add") {
                            withAnimation {
                                onboardingViewModel.assignDate = Date()
                            }
                        }
                        .matchedGeometryEffect(id: "assignButton", in: namespace)
                        .font(.body)
                    }
                    .padding(.top)
                } else {
                    VStack(alignment: .trailing) {
                        DatePicker("Assignment Date", selection: .init(get: {
                            onboardingViewModel.assignDate ?? Date()
                        }, set: { date in
                            onboardingViewModel.assignDate = date
                        }), displayedComponents: .date)
                        
                        Button("Delete") {
                            withAnimation {
                                onboardingViewModel.assignDate = nil
                            }
                        }
                        .matchedGeometryEffect(id: "assignButton", in: namespace)
                        .font(.body)
                    }
                    .padding(.top)
                }
                
                if onboardingViewModel.theBigDay == nil {
                    HStack {
                        Text("The Big Day")
                        Spacer()
                        Button("Add") {
                            withAnimation {
                                onboardingViewModel.theBigDay = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())
                            }
                        }
                        .matchedGeometryEffect(id: "bigDayButton", in: namespace)
                        .font(.body)
                    }
                    .padding(.vertical)
                } else {
                    VStack(alignment: .trailing) {
                        DatePicker("The Big Day", selection: .init(get: {
                            onboardingViewModel.theBigDay ?? Date()
                        }, set: { date in
                            onboardingViewModel.theBigDay = date
                        }), displayedComponents: .date)
                        Button("Delete") {
                            withAnimation {
                                onboardingViewModel.theBigDay = nil
                            }
                        }
                        .matchedGeometryEffect(id: "bigDayButton", in: namespace)
                        .font(.body)
                    }
                    .padding(.vertical)
                }
                Spacer()
            }
            .font(.title2)
            .bold()
            .padding(.bottom, 75)
            .buttonStyle(DepthButtonStyle(shadowRadius: 5))
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
            OnboardDatesView(index: 0).asAnyView(),
            Text("Third View").asAnyView()
        ],
        onClose: {})
    .background { ShiftingBackground().ignoresSafeArea() }
    .environmentObject(viewModel)
    .environmentObject(environment)
}
