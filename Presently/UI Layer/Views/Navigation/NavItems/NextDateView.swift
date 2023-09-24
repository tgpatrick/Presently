//
//  NextDateView.swift
//  Presently
//
//  Created by Thomas Patrick on 9/21/23.
//

import SwiftUI

struct NextDateView: ScrollNavViewType  {
    var id: String = UUID().uuidString
    @Namespace var namespace: Namespace.ID
    @ObservedObject var viewModel: ScrollViewModel
    let exchange: Exchange
    var dateFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .weekOfMonth, .month]
        formatter.unitsStyle = .full
        return formatter
    }
    
    func closedView() -> AnyView {
        VStack {
            if let assignDate = exchange.assignDate, let string = dateFormatter.string(from: Date(), to: assignDate) {
                if !exchange.started {
                    let isTomorrow = dateFormatter.calendar?.isDateInTomorrow(assignDate) ?? false
                    Text("Sit tight! Your assignments should be made" + (isTomorrow ? "" : " in:"))
                        .padding(.vertical)
                    Text(isTomorrow ? "Tomorrow" : string)
                        .font(.title2)
                        .bold()
                        .padding(.vertical)
                }
            }
            if (!exchange.started && exchange.assignDate == nil) || exchange.started {
                if let theBigDay = exchange.theBigDay, let string = dateFormatter.string(from: Date(), to: theBigDay) {
                    let isTomorrow = dateFormatter.calendar?.isDateInTomorrow(theBigDay) ?? false
                    Text("It'll be the big day" + (isTomorrow ? "" : " in:"))
                        .padding(.top)
                    Text(isTomorrow ? "Tomorrow" : string)
                        .font(.title2)
                        .bold()
                        .padding(.vertical)
                }
            } else {
                VStack {
                    Text("This gift exchange is currently")
                    if !exchange.started && exchange.assignDate == nil {
                        Text("Open")
                            .font(.title2)
                            .bold()
                        Text("Assignments have not been made")
                    } else if exchange.started && exchange.theBigDay == nil {
                        Text("")
                        Text("")
                    }
                }
                .padding(.vertical)
            }
        }
        .fillHorizontally()
        .asAnyView()
    }
}
