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
    @StateObject var profileViewModel = ProfileViewModel()
    @StateObject var personRepo = PersonRepository()
    
    @State var greetingTextField: String = ""
    @FocusState var greetingFieldFocused
    
    @State var deletedWishes: [WishListItem] = []
    @State var wishlistTextField: String = ""
    @State var wishLinkTextField: String = ""
    @State var wishHasLink: Bool = false
    @State var focusedWish: WishListItem? = nil
    @FocusState var wishlistFieldFocused
    
    let noIntroText = "Say a little bit about yourself, explain that you really don't want anything not on your list, or just say hi!"
    
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
                }
                if editState == .none || editState == .greeting {
                    SectionView(title: "Intro") {
                        if editState != .greeting {
                            if let greeting = currentUser.greeting {
                                VStack {
                                    Text(greeting)
                                        .matchedGeometryEffect(id: "greetingTextField", in: profileNamespace)
                                    Button("Edit Intro") {
                                        withAnimation {
                                            greetingTextField = greeting
                                            editState = .greeting
                                            greetingFieldFocused = true
                                        }
                                    }
                                    .matchedGeometryEffect(id: "greetingButton", in: profileNamespace)
                                }
                            } else {
                                VStack {
                                    Text(noIntroText)
                                        .foregroundStyle(Color.secondary)
                                    Button("Add Intro") {
                                        withAnimation {
                                            editState = .greeting
                                            greetingFieldFocused = true
                                        }
                                    }
                                }
                            }
                        } else {
                            VStack {
                                TextField("Introduce yourself or say hi", text: $greetingTextField, axis: .vertical)
                                    .focused($greetingFieldFocused)
                                    .matchedGeometryEffect(id: "greetingTextField", in: profileNamespace)
                                HStack {
                                    Spacer()
                                    Button("Cancel") {
                                        withAnimation {
                                            editState = .none
                                        }
                                    }
                                    .buttonStyle(DepthButtonStyle(backgroundColor: .red))
                                    Button("Save") {
                                        withAnimation {
                                            profileViewModel.saveIntro(personRepo: personRepo, environment: environment, newIntro: greetingTextField)
                                            editState = .none
                                        }
                                    }
                                    .buttonStyle(DepthButtonStyle(backgroundColor: .green))
                                }
                                .matchedGeometryEffect(id: "greetingButton", in: profileNamespace)
                                .bold()
                            }
                        }
                    }
                    .textFieldStyle(InsetTextFieldStyle(shape: RoundedRectangle(cornerRadius: 15), alignment: .leading))
                }
                if editState == .none || editState == .wishlist {
                    SectionView(title: "Wishlist") {
                        if editState != .wishlist {
                            if !currentUser.wishList.isEmpty {
                                editableWishList
                            } else {
                                Text("Add a couple ideas, some specific links, or both!")
                                    .foregroundStyle(Color.secondary)
                            }
                        } else {
                            VStack {
                                TextField("Describe something you'd like...", text: $wishlistTextField)
                                    .matchedGeometryEffect(id: wishlistTextField, in: profileNamespace)
                                    .focused($wishlistFieldFocused)
                                if wishHasLink {
                                    ZStack {
                                        TextField("Put your link here", text: $wishLinkTextField)
                                            .keyboardType(.URL)
                                            .transition(.move(edge: .top).combined(with: .opacity))
                                        if !wishLinkTextField.isEmpty {
                                            HStack {
                                                Spacer()
                                                if wishLinkTextField.isValidURL() {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundStyle(Color.green)
                                                } else {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundStyle(Color.red)
                                                }
                                            }
                                        }
                                    }
                                }
                                HStack {
                                    Spacer()
                                    Button(wishHasLink ? "Remove Link" : "Add Link") {
                                        withAnimation {
                                            wishHasLink.toggle()
                                        }
                                    }
                                    Button("Cancel") {
                                        withAnimation {
                                            wishHasLink = false
                                            editState = .none
                                        }
                                    }
                                    .buttonStyle(DepthButtonStyle(backgroundColor: .red))
                                    Button("Save") {
                                        withAnimation {
                                            if let focusedWish {
                                                profileViewModel.saveWishList(personRepo: personRepo, environment: environment, oldWish: focusedWish, newWish: WishListItem(description: wishlistTextField, link: wishLinkTextField))
                                            }
                                            editState = .none
                                        }
                                    }
                                    .buttonStyle(DepthButtonStyle(backgroundColor: .green))
                                }
                                .matchedGeometryEffect(id: "\(wishlistTextField)-WishListButton", in: profileNamespace)
                                .bold()
                            }
                        }
                    }
                    .textFieldStyle(InsetTextFieldStyle(alignment: .leading))
                }
                if editState == .none || editState == .history {
                    SectionView(title: "History") {
                        if !currentUser.giftHistory.isEmpty {
                            GiftHistoryView(giftHistory: currentUser.giftHistory)
                        } else {
                            Text("Tell us who you've given to in this group (even before Presently!) so that the algorithm can make the best assignments.")
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
            }
        }
        .fillHorizontally()
        .mainContentBox(material: .ultraThin)
        .buttonStyle(DepthButtonStyle())
        .disabled(personRepo.isLoading)
    }
    
    @ViewBuilder
    var editableWishList: some View {
        if let wishlist = environment.currentUser?.wishList {
            VStack(alignment: .leading) {
                ForEach(wishlist, id: \.self) { wish in
                    VStack(alignment: .leading) {
                        Text(wish.description)
                            .matchedGeometryEffect(id: wish.description, in: profileNamespace)
                        HStack {
                            Spacer()
                            if deletedWishes.first(where: { $0 == wish }) == nil {
                                HStack {
                                    Button("Delete") {
                                        withAnimation {
                                            deletedWishes.append(wish)
                                        }
                                    }
                                    .buttonStyle(DepthButtonStyle(backgroundColor: .red, shadowRadius: 5))
                                    Button("Edit") {
                                        withAnimation {
                                            focusedWish = wish
                                            wishlistTextField = wish.description
                                            wishHasLink = !wish.link.isEmpty
                                            wishLinkTextField = wish.link
                                            editState = .wishlist
                                            wishlistFieldFocused = true
                                        }
                                    }
                                    .buttonStyle(DepthButtonStyle(backgroundColor: .green, shadowRadius: 5))
                                }
                                .matchedGeometryEffect(id: wish.description + "-buttons", in: profileNamespace)
                            } else {
                                HStack {
                                    Button("Delete") {
                                        withAnimation {
                                            deletedWishes.removeAll(where: { $0 == wish })
                                        }
                                    }
                                    .buttonStyle(DepthButtonStyle(backgroundColor: .red, shadowRadius: 5))
                                    Button("Keep") {
                                        withAnimation {
                                            deletedWishes.removeAll(where: { $0 == wish })
                                        }
                                    }
                                    .buttonStyle(DepthButtonStyle(backgroundColor: .green, shadowRadius: 5))
                                }
                                .matchedGeometryEffect(id: wish.description + "-buttons", in: profileNamespace)
                                Text("Are you sure?")
                            }
                        }
                        .font(.caption)
                        .matchedGeometryEffect(id: "\(wish.description)-WishListButton", in: profileNamespace)
                        Divider()
                            .foregroundStyle(.primary)
                            .bold()
                    }
                }
            }
        }
    }
}

#Preview {
    var environment = AppEnvironment()
    
    return ZStack {
        ShiftingBackground()
            .ignoresSafeArea()
        ScrollView {
            ProfileView()
                .padding()
                .environmentObject(environment)
                .onAppear {
                    environment.currentUser = testPerson
                    environment.currentExchange = testExchange
                    environment.allCurrentPeople = testPeople
                }
        }
    }
}
