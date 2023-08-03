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
    @State var errorWrapper: ErrorWrapper?
    @State var exchange: Exchange?
    @State var person: Person?
    @State var people = [Person]()
    
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink("Storage", destination: {
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
                                    errorWrapper = ErrorWrapper(error: error, guidance: "Try again later.")
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
                                    errorWrapper = ErrorWrapper(error: error, guidance: "You'll have to re-enter your codes.")
                                }
                            }
                        }).buttonStyle(.borderedProminent)
                    }.navigationBarTitle("Storage")
                })
                .buttonStyle(.borderedProminent)
                
                NavigationLink("Network", destination: {
                    ScrollView {
                        TextField("Exchange ID", text: $eid)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                        TextField("Person ID", text: $pid)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                        
                        Button("Get an exchange", action: {
                            exchange = nil
                            person = nil
                            people = []
                            if eid != "" {
                                if let request = Requests.getExchange(withId: eid) {
                                    Task {
                                        let result = await Network.load(request: request)
                                        if case let .success(successResult) = result {
                                            exchange = successResult.Item
                                        } else if case let .failure(error) = result {
                                            print(error)
                                        }
                                    }
                                }
                            }
                        })
                        .buttonStyle(.borderedProminent)
                        
                        Button("Get a person", action: {
                            exchange = nil
                            person = nil
                            people = []
                            if eid != "" && pid != "" {
                                if let request = Requests.getPerson(exchangeId: eid, personId: pid) {
                                    Task {
                                        let result = await Network.load(request: request)
                                        if case let .success(successResult) = result {
                                            person = successResult.Item
                                        } else if case let .failure(error) = result {
                                            print(error)
                                        }
                                    }
                                }
                            }
                        })
                        .buttonStyle(.borderedProminent)
                        
                        Button("Get all people", action: {
                            exchange = nil
                            person = nil
                            people = []
                            if eid != "" {
                                if let request = Requests.getAllPeople(fromExchange: eid) {
                                    Task {
                                        let result = await Network.load(request: request)
                                        if case let .success(successResult) = result {
                                            people = successResult.Items
                                        } else if case let .failure(error) = result {
                                            print(error)
                                        }
                                    }
                                }
                            }
                        })
                        .buttonStyle(.borderedProminent)
                        
                        Text("Results:")
                            .font(.title2)
                        if let exchange = exchange {
                            Text("Got an exchange!")
                                .font(.title3)
                            Text("Name: \(exchange.name)")
                            Text("ID: \(exchange.id)")
                        }
                        
                        if let person = person {
                            Text("Got a person!")
                                .font(.title3)
                            Text("Name: \(person.name)")
                            Text("ID: \(person.personId)")
                        }
                        
                        if people.count > 0 {
                            Text("Got all people!")
                                .font(.title3)
                            ForEach(people) { person in
                                Text(person.name)
                            }
                        }
                    }.navigationBarTitle("Network")
                })
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Presently Testing")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(loginStorage: LoginStorage())
    }
}
