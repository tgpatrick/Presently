//
//  TestView.swift
//  Presently
//
//  Created by Thomas Patrick on 8/3/23.
//

import SwiftUI

struct TestView: View {
    @EnvironmentObject var loginStorage: LoginStorage
    @State var selectedLogin: LoginStorageItem?
    @State var ename = ""
    @State var pname = ""
    @State var eid = ""
    @State var pid = ""
    @State var errorWrapper: ErrorWrapper?
    @State var exchange: Exchange?
    @State var person: Person?
    @State var people: People?
    @StateObject var exchangeRepo = ExchangeRepository()
    @StateObject var personRepo = PersonRepository()
    @StateObject var peopleRepo = PeopleRepository()
    var loading: Bool {
        exchangeRepo.isLoading || personRepo.isLoading || peopleRepo.isLoading
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
                            }).buttonStyle(DepthButtonStyle())
                            
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
                                if let selectedLogin {
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
                            }).buttonStyle(DepthButtonStyle())
                        }
                        .navigationTitle("Storage")
                    })
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
                            .buttonStyle(DepthButtonStyle())
                            
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
                            .buttonStyle(DepthButtonStyle())
                            
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
                            .buttonStyle(DepthButtonStyle())
                            
                            Text("Results:")
                                .font(.title2)
                            
                            if loading {
                                ProgressView()
                            }
                            
                            if let exchange {
                                Text("Got an exchange!")
                                    .font(.title3)
                                Text("Name: \(exchange.name)")
                                Text("ID: \(exchange.id)")
                            }
                            
                            if let person {
                                Text("Got a person!")
                                    .font(.title3)
                                Text("Name: \(person.name)")
                                Text("ID: \(person.personId)")
                            }
                            
                            if let people, !people.isEmpty {
                                Text("Got all people!")
                                    .font(.title3)
                                ForEach(people) { person in
                                    Text(person.name)
                                }
                            }
                        }
                        .navigationTitle("Network")
                    })
                    .font(.title)
//                    Spacer()
//                    Button("Testing") {
//                        do {
//                            let data = try JSONEncoder().encode(testExchange)
//                            print(String(data: data, encoding: .utf8))
//                        } catch {
//                            print(error)
//                        }
//                    }
//                    .font(.title2)
                    Spacer()
                }
                .toolbar(.hidden)
                .buttonStyle(DepthButtonStyle())
            }
            
            if let errorWrapper {
                VStack {
                    Text("Error")
                        .font(.title)
                        .bold()
                    Text(errorWrapper.error.localizedDescription)
                    Text(errorWrapper.guidance)
                    Button("Okay", action: {
                        self.errorWrapper = nil
                    })
                    .buttonStyle(DepthButtonStyle())
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding()
            }
        }
    }
}

#Preview {
    TestView()
        .environmentObject(LoginStorage())
}
