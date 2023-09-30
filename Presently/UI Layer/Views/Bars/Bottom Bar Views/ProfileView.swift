//
//  ProfileView.swift
//  Presently
//
//  Created by Thomas Patrick on 9/30/23.
//

import SwiftUI

enum ProfileEditState: String {
    case greeting
    case wishlist
    case history
    case none
}

struct ProfileView: View {
    @EnvironmentObject var environment: AppEnvironment
    @State var editState: ProfileEditState = .none
    
    @Namespace var profileNamespace
    
    var body: some View {
        VStack(spacing: 20) {
            if let currentUser = environment.currentUser {
                if editState == .none {
                    VStack {
                        Text(currentUser.name)
                            .font(.title2)
                            .bold()
                        Text("\(currentUser.exchangeId)-\(currentUser.personId)")
                    }
                    .mainContentBox(material: .ultraThin)
                    Spacer()
                }
                if editState == .none || editState == .greeting {
                    VStack {
                        editTitleBar(title: "Greeting", editState: .greeting)
                        Spacer()
                    }
                    .fillHorizontally()
                    .mainContentBox(material: .ultraThin)
                    Spacer()
                }
                if editState == .none || editState == .wishlist {
                    VStack {
                        editTitleBar(title: "Wishlist", editState: .wishlist)
                        Spacer()
                    }
                    .fillHorizontally()
                    .mainContentBox(material: .ultraThin)
                    Spacer()
                }
                if editState == .none || editState == .history {
                    VStack {
                        editTitleBar(title: "History", editState: .history)
                        Spacer()
                    }
                    .fillHorizontally()
                    .mainContentBox(material: .ultraThin)
                    Spacer()
                }
            }
        }
        .fillHorizontally()
        .padding()
    }
    
    func editTitleBar(title: String, editState: ProfileEditState) -> some View {
        ZStack(alignment: .center) {
            VStack {
                Text(title)
                    .font(.title2)
                    .bold()
            }
            HStack {
                Spacer()
                if self.editState != editState {
                    Button {
                        withAnimation {
                            self.editState = editState
                        }
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 25)
                    }
                    .matchedGeometryEffect(id: "editButton\(editState.rawValue)", in: profileNamespace)
                } else {
                    HStack {
                        Button {
                            withAnimation {
                                self.editState = .none
                            }
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 25)
                                .foregroundStyle(.green)
                        }
                        
                        Button {
                            withAnimation {
                                self.editState = .none
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 25)
                                .foregroundStyle(.red)
                        }
                    }
                    .matchedGeometryEffect(id: "editButton\(editState.rawValue)", in: profileNamespace)
                }
            }
        }
        .padding()
    }
}

#Preview {
    var environment = AppEnvironment()
    
    return ProfileView()
        .environmentObject(environment)
        .onAppear {
            environment.currentUser = testPerson
        }
}
