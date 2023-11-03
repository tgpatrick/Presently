//
//  ExchangeView.swift
//  Presently
//
//  Created by Thomas Patrick on 8/22/23.
//

import SwiftUI

struct ExchangeNavItem: NavItemView {
    var id: String = UUID().uuidString
    // var title: String? = "Your exchange"
    @Namespace var namespace: Namespace.ID
    @EnvironmentObject var viewModel: ScrollViewModel
    
    let userName: String
    let exchange: Exchange
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    func closedView() -> AnyView {
        VStack {
            Group {
                Text("Hello ") + Text(userName).bold() + Text("!\nHere is your info from:")
            }
            .multilineTextAlignment(.center)
            
            Button {
                viewModel.focus(self.id)
            } label: {
                VStack {
                    Text(exchange.name)
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                        .navTitleMatchAnimation(namespace: namespace)
                    HStack {
                        Text("Details")
                        Image(systemName: "chevron.forward")
                    }
                    .bold()
                    .foregroundStyle(Color(.accent))
                }
                .buttonStyle(NavListButtonStyle())
            }
            .padding()
            .contentShape(RoundedRectangle(cornerRadius: 15))
            .foregroundStyle(.primary)
            .contextMenu {
                Button {
                    viewModel.focus(self.id)
                } label: {
                    Label("Open", systemImage: "chevron.forward")
                }
            } preview: {
                VStack(alignment: .center, spacing: 10) {
                    Text(exchange.name)
                        .font(.title3)
                        .bold()
                    HStack {
                        Text("Secret:")
                        Spacer()
                        Text(exchange.secret ? "Yes" : "No")
                    }
                    HStack {
                        Text("Repeating:")
                        Spacer()
                        Text(exchange.repeating ? "Yes" : "No")
                    }
                    if (!exchange.started && exchange.assignDate != nil) || exchange.theBigDay != nil {
                        let assignAvailable = !exchange.started && exchange.assignDate != nil
                        HStack {
                            Text(assignAvailable ? "Starting:" : "The Big Day:")
                            Spacer()
                            if let date = (assignAvailable ? exchange.assignDate : exchange.theBigDay) {
                                Text(dateFormatter.string(from: date))
                            }
                        }
                    }
                }
                .padding()
            }
            .accessibilityLabel("ExchangeDetailButton")
        }
        .asAnyView()
    }
    
    func openView() -> AnyView {
        VStack {
            TitledScrollView(title: exchange.name, namespace: namespace) {
                SectionView(title: "Intro") {
                    Text(exchange.intro)
                        .accessibilityLabel("IntroText")
                }
                
                SectionView(title: "Rules") {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(exchange.rules)
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
                            if !exchange.started {
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
        }
        .asAnyView()
    }
    
    var isSecretMessage: String {
        let firstDifference = exchange.secret ? " secret" : "n open"
        let secondDifference = exchange.secret ? "can't " : "can "
        
        return "This is a" + firstDifference + " exchange. You " + secondDifference + "see who everyone is assigned to."
    }
    
    var isRepeatingMessage: String {
        let firstDifference = exchange.repeating ? "will" : "will NOT"
        
        return "This exchange " + firstDifference + " repeat."
    }
}

#Preview {
    var viewModel = ScrollViewModel()
    
    return NavigationScrollView(viewModel: viewModel, items: [
        ExchangeNavItem(userName: testPerson.name, exchange: testExchange)
    ])
    .environmentObject(viewModel)
}
