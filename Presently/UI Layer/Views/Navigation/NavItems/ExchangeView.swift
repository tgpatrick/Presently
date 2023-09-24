//
//  ExchangeView.swift
//  Presently
//
//  Created by Thomas Patrick on 8/22/23.
//

import SwiftUI

struct ExchangeView: ScrollNavViewType {
    var id: String = UUID().uuidString
//    var title: String? = "Your exchange"
    @Namespace var namespace: Namespace.ID
    @ObservedObject var viewModel: ScrollViewModel
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
                Text("Hello ") + Text(userName).bold() + Text(", here is your info from:")
            }
            .font(.caption)
            VStack {
                Text(exchange.name)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .navTitleMatchAnimation(namespace: namespace)
                
                Button {
                    viewModel.focus(self.id)
                } label: {
                    HStack {
                        Text("Details")
                        Image(systemName: "chevron.forward")
                    }
                    .bold()
                }
            }
            .padding()
            .contentShape(RoundedRectangle(cornerRadius: 15))
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
            Text(exchange.name)
                .modifier(NavTitleModifier(namespace: namespace))
            
            VStack(alignment: .leading, spacing: 10) {
                Text(exchange.intro)
                    .padding(.bottom, 15)
                Text("Rules:")
                    .font(.title3)
                    .bold()
                    .padding(.leading)
                Text(exchange.rules)
                Text(isSecretMessage(isSecret: exchange.secret))
                Text(isRepeatingMessage(isRepeating: exchange.repeating))
                Text("Status:")
                    .font(.title3)
                    .bold()
                    .padding(.leading)
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
            .padding(.top)
            Spacer()
        }
        .asAnyView()
    }
    
    func isSecretMessage(isSecret: Bool) -> String {
        let firstDifference = isSecret ? " secret" : "n open"
        let secondDifference = isSecret ? "can't " : "can "
        
        return "This is a" + firstDifference + " exchange. You " + secondDifference + "see who everyone is assigned to."
    }
    
    func isRepeatingMessage(isRepeating: Bool) -> String {
        let firstDifference = isRepeating ? "will" : "will NOT"
        
        return "This exchange " + firstDifference + " repeat."
    }
}

struct ExchangeView_Previews: PreviewProvider {
    static var viewModel = ScrollViewModel()
    
    static var previews: some View {
        NavigationScrollView(viewModel: viewModel, items: [
            ExchangeView(viewModel: viewModel, userName: testPerson.name, exchange: testExchange)
        ])
    }
}
