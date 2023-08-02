//
//  ContentView.swift
//  Presently
//
//  Created by Thomas Patrick on 8/1/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var loginStorage: LoginStorage
    @State var selectedLogin: LoginStorageItem?
    @State var ename = ""
    @State var pname = ""
    @State var eid = ""
    @State var pid = ""
    
    var body: some View {
        ScrollView {
            TextField("Exchange Name", text: $ename)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            TextField("Person Name", text: $pname)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            TextField("Exchange ID", text: $eid)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            TextField("Person ID", text: $pid)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            Button("Add a Login", action: {
                Task {
                    do {
                        try await loginStorage.save(
                            LoginStorageItem(
                                exchangeName: ename,
                                personName: pname,
                                exchangeID: eid,
                                personID: pid)
                        )
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }).buttonStyle(.borderedProminent)
            
            ForEach(loginStorage.items) { login in
                Button(action: {
                    selectedLogin = login
                }) {
                    HStack {
                        VStack {
                            Text(login.exchangeName)
                            Text(login.exchangeID)
                        }
                        Spacer()
                        VStack {
                            Text(login.personName)
                            Text(login.personID)
                        }
                    }
                    .background(selectedLogin == login ? Color.gray : Color.clear)
                    .cornerRadius(10)
                }
            }
            Button("Delete a Login", action: {
                Task {
                    do {
                        try await loginStorage.delete(
                            LoginStorageItem(
                                exchangeName: ename,
                                personName: pname,
                                exchangeID: eid,
                                personID: pid)
                        )
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }).buttonStyle(.borderedProminent)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(loginStorage: LoginStorage())
    }
}
