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
    @State var people: [Person]?
    @StateObject var exchangeRepo = ExchangeRepository()
    @StateObject var personRepo = PersonRepository()
    @StateObject var peopleRepo = PeopleRepository()
    var loading: Bool {
        if case .loading = exchangeRepo.loadingState {
            return true
        } else if case .loading = personRepo.loadingState {
            return true
        } else if case .loading = peopleRepo.loadingState {
            return true
        }
        return false
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    Spacer()
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
                                    await loginStorage.save(
                                        LoginStorageItem(
                                            exchangeName: ename,
                                            personName: pname,
                                            exchangeID: eid,
                                            personID: pid)
                                    )
                                }
                            }).buttonStyle(.borderedProminent)
                            
                            ForEach(loginStorage.items) { login in
                                HStack {
                                    VStack {
                                        Text("Exchange:").bold()
                                        Text(login.exchangeName)
                                        Text(login.exchangeID)
                                    }
                                    Spacer()
                                    VStack {
                                        Text("Person:").bold()
                                        Text(login.personName)
                                        Text(login.personID)
                                    }
                                }
                                .padding()
                                .background(selectedLogin == login ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .padding()
                                .onTapGesture {
                                    selectedLogin = login
                                }
                            }
                            Button("Delete a Login", action: {
                                if let selectedLogin = selectedLogin {
                                    Task {
                                        await loginStorage.delete(
                                            LoginStorageItem(
                                                exchangeName: selectedLogin.exchangeName,
                                                personName: selectedLogin.personName,
                                                exchangeID: selectedLogin.exchangeID,
                                                personID: selectedLogin.personID)
                                        )
                                    }
                                }
                            }).buttonStyle(.borderedProminent)
                        }.navigationBarTitle("Storage")
                    })
                    .buttonStyle(.borderedProminent)
                    .font(.title)
                    Spacer()
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
                                    Task {
                                        await exchangeRepo.get(eid)
                                        if case .success = exchangeRepo.loadingState {
                                            exchange = exchangeRepo.storage
                                        } else if case let .error(error) = exchangeRepo.loadingState {
                                            errorWrapper = error
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
                                    Task {
                                        await personRepo.get(eid + pid)
                                        if case .success = personRepo.loadingState {
                                            person = personRepo.storage
                                        } else if case let .error(error) = personRepo.loadingState {
                                            errorWrapper = error
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
                                    Task {
                                        await peopleRepo.get(eid)
                                        if case .success = peopleRepo.loadingState {
                                            people = peopleRepo.storage
                                        } else if case let .error(error) = peopleRepo.loadingState {
                                            errorWrapper = error
                                        }
                                    }
                                }
                            })
                            .buttonStyle(.borderedProminent)
                            
                            Text("Results:")
                                .font(.title2)
                            
                            if loading {
                                ProgressView()
                            }
                            
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
                            
                            if let people = people, people.count > 0 {
                                Text("Got all people!")
                                    .font(.title3)
                                ForEach(people) { person in
                                    Text(person.name)
                                }
                            }
                        }.navigationBarTitle("Network")
                    })
                    .buttonStyle(.borderedProminent)
                    .font(.title)
                    Spacer()
                }
                .navigationTitle("Presently Testing")
            }
            
            if let errorWrapper = errorWrapper {
                VStack {
                    Text("Error")
                        .font(.title)
                        .bold()
                    Text(errorWrapper.error.localizedDescription)
                    Text(errorWrapper.guidance)
                    Button("Okay", action: {
                        self.errorWrapper = nil
                    })
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color.gray.opacity(0.9))
                .cornerRadius(15)
                .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(loginStorage: LoginStorage())
    }
}
