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
    case exclusions
    case none
}

struct ProfileView: View {
    @EnvironmentObject var environment: AppEnvironment
    @State private var editState: ProfileEditState = .none
    
    @Namespace var profileNamespace
    @StateObject var profileViewModel = ProfileViewModel()
    @StateObject var personRepo = PersonRepository()
    
    @State private var greetingTextField: String = ""
    @FocusState private var greetingFieldFocused
    
    @State private var deletedWishes: [WishListItem] = []
    @State private var wishlistTextField: String = ""
    @State private var wishLinkTextField: String = ""
    @State private var wishHasLink: Bool = false
    @State private var focusedWish: WishListItem? = nil
    @FocusState var wishlistFieldFocused
    @FocusState var linkFieldFocused
    
    private let thisYear: Int = Calendar.current.component(.year, from: .now)
    @State private var giftYear = Calendar.current.component(.year, from: Calendar.current.date(byAdding: .year, value: -1, to: .now) ?? .now)
    @State private var giftRecipientId = ""
    @State var focusedGift: HistoricalGift? = nil
    
    @State private var exclusionToDelete: String?
    @State private var exclusionId = ""
    
    let noIntroText = "Say a little about yourself, explain that you're excited to receive something from your very specific wish list, or just say hi!"
    
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
                        VStack(alignment: .leading) {
                            if editState != .greeting {
                                if let greeting = currentUser.greeting {
                                    Text(greeting)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .matchedGeometryEffect(id: "greetingTextField", in: profileNamespace)
                                    Button("Edit Intro") {
                                        withAnimation {
                                            greetingTextField = greeting
                                            editState = .greeting
                                            greetingFieldFocused = true
                                        }
                                    }
                                    .matchedGeometryEffect(id: "greetingButton", in: profileNamespace)
                                    .fillHorizontally()
                                } else {
                                    Text(noIntroText)
                                        .foregroundStyle(Color.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .multilineTextAlignment(.center)
                                        .fillHorizontally()
                                    Button("Add Intro") {
                                        withAnimation {
                                            editState = .greeting
                                            greetingFieldFocused = true
                                        }
                                    }
                                    .fillHorizontally()
                                }
                            } else {
                                VStack {
                                    TextField("Introduce yourself or say hi", text: $greetingTextField, axis: .vertical)
                                        .focused($greetingFieldFocused)
                                        .matchedGeometryEffect(id: "greetingTextField", in: profileNamespace)
                                        .textFieldStyle(InsetTextFieldStyle(shape: RoundedRectangle(cornerRadius: 15), alignment: .leading, minHeight: 50))
                                    HStack {
                                        Spacer()
                                        Button("Cancel") {
                                            withAnimation {
                                                greetingFieldFocused = false
                                                editState = .none
                                            }
                                        }
                                        .buttonStyle(DepthButtonStyle(backgroundColor: .red))
                                        Button {
                                            Task {
                                                await profileViewModel.saveIntro(personRepo: personRepo, environment: environment, newIntro: greetingTextField)
                                                if personRepo.succeeded {
                                                    DispatchQueue.main.async {
                                                        withAnimation {
                                                            editState = .none
                                                        }
                                                    }
                                                }
                                            }
                                        } label: {
                                            if personRepo.isLoading {
                                                ProgressView()
                                            } else {
                                                Text("Save")
                                            }
                                        }
                                        .buttonStyle(DepthButtonStyle(backgroundColor: .green))
                                        .disabled(personRepo.isLoading)
                                    }
                                    .foregroundStyle(Color.black)
                                    .matchedGeometryEffect(id: "greetingButton", in: profileNamespace)
                                    .bold()
                                }
                            }
                        }
                    }
                }
                if editState == .none || editState == .wishlist {
                    SectionView(title: "Wishlist") {
                        if editState != .wishlist {
                            VStack {
                                if !currentUser.wishList.isEmpty {
                                    editableWishList
                                } else {
                                    Text("Add a couple general ideas, some specific links, or both!")
                                        .foregroundStyle(Color.secondary)
                                        .multilineTextAlignment(.center)
                                        .fillHorizontally()
                                }
                                Button("Add a wish") {
                                    withAnimation {
                                        editState = .wishlist
                                        wishlistFieldFocused = true
                                    }
                                }
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
                                            .focused($linkFieldFocused)
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
                                            focusedWish = nil
                                            wishlistTextField = ""
                                            wishLinkTextField = ""
                                            wishlistFieldFocused = false
                                            linkFieldFocused = false
                                            wishHasLink = false
                                            editState = .none
                                        }
                                    }
                                    .buttonStyle(DepthButtonStyle(backgroundColor: .red))
                                    Button {
                                        Task {
                                            await profileViewModel.saveWishList(personRepo: personRepo, environment: environment, oldWish: focusedWish, newWish: WishListItem(description: wishlistTextField, link: wishLinkTextField))
                                            if personRepo.succeeded {
                                                DispatchQueue.main.async {
                                                    withAnimation {
                                                        focusedWish = nil
                                                        wishlistTextField = ""
                                                        wishLinkTextField = ""
                                                        editState = .none
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        if case .loading = personRepo.loadingState {
                                            ProgressView()
                                        } else {
                                            Text("Save")
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
                        VStack {
                            Text("Please note: for the moment, you can only edit or delete the record of who you gave to")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            if editState != .history {
                                if !currentUser.giftHistory.isEmpty {
                                    GiftHistoryView(
                                        user: currentUser,
                                        onEdit: { gift in
                                            giftYear = gift.year
                                            giftRecipientId = gift.recipientId
                                            focusedGift = gift
                                            withAnimation {
                                                editState = .history
                                            }
                                        },
                                        onDelete: { gift in
                                            Task {
                                                await profileViewModel.deleteGift(personRepo: personRepo, environment: environment, gift: gift)
                                            }
                                        })
                                    .matchedGeometryEffect(id: "GiftHistory", in: profileNamespace)
                                } else {
                                    Text("Tell us who you've given to in this group (even before Presently!) so that the algorithm can make the best assignments.")
                                        .foregroundStyle(Color.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .multilineTextAlignment(.center)
                                        .fillHorizontally()
                                }
                                Button("Add a gift") {
                                    withAnimation {
                                        editState = .history
                                    }
                                }
                                .padding(.bottom)
                            } else {
                                VStack(spacing: 0) {
                                    VStack(spacing: 0) {
                                        HStack(spacing: 0) {
                                            Text("In")
                                            Picker("Select a year", selection: $giftYear) {
                                                ForEach(2000..<thisYear, id: \.self) { year in
                                                    Text("\(String(year))").tag(year)
                                                }
                                            }
                                        }
                                        HStack(spacing: 0) {
                                            Text("I gave to")
                                            Picker("Select a name", selection: $giftRecipientId) {
                                                ForEach(environment.allCurrentPeople ?? []) { person in
                                                    if person != environment.currentUser {
                                                        Text(person.name).tag(person.personId)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .mainContentBox(material: .ultraThin)
                                    .matchedGeometryEffect(id: "GiftHistory", in: profileNamespace)
                                    HStack {
                                        Spacer()
                                        Button("Cancel") {
                                            focusedGift = nil
                                            withAnimation {
                                                editState = .none
                                            }
                                        }
                                        .buttonStyle(DepthButtonStyle(backgroundColor: .red))
                                        Spacer()
                                        Button {
                                            Task {
                                                await profileViewModel.saveGift(personRepo: personRepo, environment: environment, oldGift: focusedGift, newGift: HistoricalGift(year: giftYear, recipientId: giftRecipientId, description: ""))
                                                if personRepo.succeeded {
                                                    DispatchQueue.main.async {
                                                        focusedGift = nil
                                                        withAnimation {
                                                            editState = .none
                                                        }
                                                    }
                                                }
                                            }
                                        } label: {
                                            if personRepo.isLoading {
                                                ProgressView()
                                            } else {
                                                Text("Save")
                                            }
                                        }
                                        .buttonStyle(DepthButtonStyle(backgroundColor: .green))
                                        Spacer()
                                    }
                                    .padding(.vertical)
                                    .foregroundStyle(Color.black)
                                }
                            }
                        }
                    }
                }
                if editState == .none || editState == .exclusions {
                    SectionView(title: "Exclusions") {
                        if editState != .exclusions {
                            VStack {
                                if !currentUser.exceptions.isEmpty {
                                    ForEach(currentUser.exceptions, id: \.self) { exclusion in
                                        VStack(alignment: .leading) {
                                            Text(environment.getPerson(id: exclusion)?.name ?? "")
                                                .bold()
                                            HStack {
                                                Spacer()
                                                Button("Delete") {
                                                    if exclusionToDelete != exclusion {
                                                        withAnimation {
                                                            exclusionToDelete = exclusion
                                                        }
                                                    } else {
                                                        Task {
                                                            await profileViewModel.deleteExclusion(personRepo: personRepo, environment: environment, exclusion: exclusion)
                                                        }
                                                    }
                                                }
                                                .buttonStyle(DepthButtonStyle(backgroundColor: .red))
                                                .foregroundStyle(Color.black)
                                                if exclusionToDelete == exclusion {
                                                    Button("Keep") {
                                                        withAnimation {
                                                            exclusionToDelete = nil
                                                        }
                                                    }
                                                    .buttonStyle(DepthButtonStyle(backgroundColor: .green))
                                                    .foregroundStyle(Color.black)
                                                    Text("Are you sure?")
                                                }
                                            }
                                            Divider()
                                        }
                                    }
                                }
                                Button("Add an exclusion") {
                                    withAnimation {
                                        editState = .exclusions
                                    }
                                }
                            }
                            .fillHorizontally()
                        } else {
                            VStack(spacing: 0) {
                                HStack {
                                    Text("I can't give to")
                                    Picker("Select a name", selection: $exclusionId) {
                                        ForEach(environment.allCurrentPeople ?? []) { person in
                                            if person != environment.currentUser {
                                                Text(person.name).tag(person.personId)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                HStack {
                                    Spacer()
                                    Button("Cancel") {
                                        withAnimation {
                                            editState = .none
                                        }
                                    }
                                    .buttonStyle(DepthButtonStyle(backgroundColor: .red))
                                    Spacer()
                                    Button {
                                        Task {
                                            if exclusionId != "", let exclusionToDelete {
                                                await profileViewModel.saveExclusion(personRepo: personRepo, environment: environment, exclusion: exclusionToDelete)
                                                DispatchQueue.main.async {
                                                    withAnimation {
                                                        editState = .none
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        if !personRepo.isLoading {
                                            Text("Save")
                                        } else {
                                            ProgressView()
                                        }
                                    }
                                    .buttonStyle(DepthButtonStyle(backgroundColor: .green))
                                    Spacer()
                                }
                                .padding(.vertical)
                                .foregroundStyle(Color.black)
                            }
                        }
                    }
                }
            }
        }
        .fillHorizontally()
        .mainContentBox()
        .alert("Network Error", isPresented: .init(
            get: {
                if case .error(_) = personRepo.loadingState {
                    return true
                } else {
                    return false
                }
            }, set: { value in
                if !value {
                    personRepo.loadingState = .resting
                }
            })) {
                if let lastRequest = profileViewModel.lastRequest {
                    Button("Try again") {
                        if lastRequest == .intro {
                            Task {
                                await profileViewModel.saveIntro(
                                    personRepo: personRepo,
                                    environment: environment,
                                    newIntro: greetingTextField)
                            }
                        } else if lastRequest == .wishList {
                            Task {
                                await profileViewModel.saveWishList(
                                    personRepo: personRepo,
                                    environment: environment,
                                    oldWish: focusedWish,
                                    newWish: WishListItem(
                                        description: wishlistTextField,
                                        link: wishLinkTextField))
                            }
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .buttonStyle(DepthButtonStyle())
            .disabled(personRepo.isLoading)
            .onChange(of: editState) { _, state in
                withAnimation(.easeInOut) {
                    deletedWishes = []
                    exclusionToDelete = nil
                    environment.hideTabBar = (state != .none)
                }
            }
    }
    
    @ViewBuilder
    var editableWishList: some View {
        if let wishlist = environment.currentUser?.wishList {
            ForEach(wishlist, id: \.self) { wish in
                VStack(alignment: .leading) {
                    Text(wish.description)
                        .fixedSize(horizontal: false, vertical: true)
                        .matchedGeometryEffect(id: wish.description, in: profileNamespace)
                    HStack {
                        if !wish.link.isEmpty, let url = URL(string: wish.link) {
                            Link(destination: url) {
                                HStack(spacing: 5) {
                                    Text("Link")
                                        .bold()
                                    Image(.externalLink)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundStyle(.primary)
                                        .frame(height: 15)
                                }
                                .padding(.horizontal, 2)
                            }
                            .padding(.leading, 5)
                        }
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
                                .foregroundStyle(Color.black)
                                .buttonStyle(DepthButtonStyle(backgroundColor: .green, shadowRadius: 5))
                            }
                            .matchedGeometryEffect(id: wish.description + "-buttons", in: profileNamespace)
                            .foregroundStyle(Color.black)
                        } else {
                            HStack {
                                Button {
                                    Task {
                                        await profileViewModel.deleteWish(personRepo: personRepo, environment: environment, wish: wish)
                                        withAnimation {
                                            deletedWishes.removeAll(where: { $0 == wish })
                                        }
                                    }
                                } label: {
                                    if case .loading = personRepo.loadingState, deletedWishes.contains(where: { $0 == wish }) {
                                        ProgressView()
                                    } else {
                                        Text("Delete")
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
                            .foregroundStyle(Color.black)
                            .matchedGeometryEffect(id: wish.description + "-buttons", in: profileNamespace)
                            Text("Are you sure?")
                        }
                    }
                    .font(.caption)
                    .frame(maxHeight: 25)
                    .padding(.vertical, 10)
                    .matchedGeometryEffect(id: "\(wish.description)-WishListButton", in: profileNamespace)
                    Divider()
                        .foregroundStyle(.primary)
                        .bold()
                }
                .padding(.top)
            }
        }
    }
}


#Preview {
    let environment = AppEnvironment()
    
    return ZStack {
        ShiftingBackground()
            .ignoresSafeArea()
        ScrollView {
            ProfileView()
                .padding()
                .environmentObject(environment)
                .onAppear {
                    environment.currentUser = testPerson3
                    environment.currentExchange = testExchange
                    environment.allCurrentPeople = testPeople
                }
        }
    }
}
