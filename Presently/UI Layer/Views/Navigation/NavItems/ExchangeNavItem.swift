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
    @ObservedObject var viewModel: ScrollViewModel
    private let userName: String
    private let exchange: Exchange
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    init(viewModel: ScrollViewModel) {
        self.viewModel = viewModel
        self.userName = viewModel.currentUser().name
        self.exchange = viewModel.currentExchange()
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
        }
        .asAnyView()
    }
    
    func openView() -> AnyView {
        VStack {
            TitledScrollView(title: exchange.name, namespace: namespace) {
                SectionView(title: "Intro") {
                    Text(exchange.intro)
                }
                
                SectionView(title: "Rules") {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(exchange.rules)
                        Text(isSecretMessage)
                        Text(isRepeatingMessage)
                    }
                }
                
                SectionView(title: "Status: \(exchange.started ? "Started" : "Open")") {
                    HStack {
                        Spacer()
                        if !exchange.started {
                            VStack {
                                Text("Open")
                                    .font(.title3)
                                    .bold()
                                Text("Assignments have not been made and people can still be added.")
                                    .multilineTextAlignment(.center)
                            }
                        } else {
                            VStack {
                                Text("Started")
                                    .font(.title3)
                                    .bold()
                                Text("Assignments have been made. Next step is gift giving!")
                                    .multilineTextAlignment(.center)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .asAnyView()
    }
    
    var isSecretMessage: String {
        let firstDifference = self.exchange.secret ? " secret" : "n open"
        let secondDifference = self.exchange.secret ? "can't " : "can "
        
        return "This is a" + firstDifference + " exchange. You " + secondDifference + "see who everyone is assigned to."
    }
    
    var isRepeatingMessage: String {
        let firstDifference = self.exchange.repeating ? "will" : "will NOT"
        
        return "This exchange " + firstDifference + " repeat."
    }
}

#Preview {
    var viewModel = ScrollViewModel()
    
    return NavigationScrollView(viewModel: viewModel, items: [
        ExchangeNavItem(viewModel: viewModel)
    ])
}
