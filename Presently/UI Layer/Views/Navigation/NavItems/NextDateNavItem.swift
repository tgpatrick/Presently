//
//  NextDateView.swift
//  Presently
//
//  Created by Thomas Patrick on 9/21/23.
//

import SwiftUI

struct NextDateNavItem: NavItemView  {
    var id: String = UUID().uuidString
    @Namespace var namespace: Namespace.ID
    @ObservedObject var viewModel: ScrollViewModel
    private let exchange: Exchange
    var dateFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .weekOfMonth, .month]
        formatter.unitsStyle = .full
        return formatter
    }
    
    init(viewModel: ScrollViewModel) {
        self.viewModel = viewModel
        self.exchange = viewModel.currentExchange()
    }
    
    func closedView() -> AnyView {
        VStack {
            if let assignDate = exchange.assignDate, let string = dateFormatter.string(from: Date(), to: assignDate) {
                if !exchange.started {
                    let isTomorrow = dateFormatter.calendar?.isDateInTomorrow(assignDate) ?? false
                    Text("Assignments should be made" + (isTomorrow ? "" : " in:"))
                        .font(.title2)
                        .bold()
                        .padding(.vertical)
                    Text(isTomorrow ? "Tomorrow" : string)
                        .font(.title)
                        .bold()
                    Text("Sit tight!")
                        .padding(.vertical)
                }
            }
            if (!exchange.started && exchange.assignDate == nil) || exchange.started {
                if let theBigDay = exchange.theBigDay, let formattedDate = dateFormatter.string(from: Date(), to: theBigDay) {
                    let isTomorrow = dateFormatter.calendar?.isDateInTomorrow(theBigDay) ?? false
                    Text("It'll be the big day" + (isTomorrow ? "" : " in:"))
                        .font(.title2)
                        .bold()
                    Text(isTomorrow ? "Tomorrow" : formattedDate)
                        .font(.title)
                        .bold()
                        .padding(.vertical)
                }
            } else {
                VStack {
                    Text("This gift exchange is currently")
                    if !exchange.started && exchange.assignDate == nil {
                        Text("Open")
                            .font(.title)
                            .bold()
                            .padding(.vertical)
                        Text("Assignments have not been made")
                    } else if exchange.started && exchange.theBigDay == nil {
                        Text("Started")
                            .font(.title)
                            .bold()
                        Text("Sit tight!")
                            .padding(.vertical)
                    }
                }
                .padding(.vertical)
            }
        }
        .fillHorizontally()
        .asAnyView()
    }
}

#Preview {
    var viewModel = ScrollViewModel()
    
    return NavigationScrollView(viewModel: viewModel, items: [
        NextDateNavItem(viewModel: viewModel)
    ])
}
