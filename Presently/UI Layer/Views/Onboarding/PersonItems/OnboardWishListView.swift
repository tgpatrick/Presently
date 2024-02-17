//
//  OnboardWishListView.swift
//  Presently
//
//  Created by Thomas Patrick on 11/3/23.
//

import SwiftUI

struct OnboardWishListView: View {
    @EnvironmentObject var onboardingViewModel: PersonOnboardingViewModel
    @Namespace var namespace
    
    @State var showTextFields = false
    @State var deletedWishes: [WishListItem] = []
    @State var wishlistTextField: String = ""
    @State var wishLinkTextField: String = ""
    @State var wishHasLink: Bool = false
    @State var focusedWish: WishListItem? = nil
    @FocusState var wishlistFieldFocused
    @FocusState var linkFieldFocused
    
    var body: some View {
        VStack {
            Text("Wish List")
                .font(.title)
                .bold()
            if !showTextFields {
                Text("Add items to your wish list help out your gift-giver. Add a couple ideas, some specific links, or both!")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            if showTextFields {
                VStack {
                    TextField("Describe something you'd like...", text: $wishlistTextField)
                        .matchedGeometryEffect(id: wishlistTextField, in: namespace)
                        .focused($wishlistFieldFocused)
                    if wishHasLink {
                        ZStack {
                            TextField("Paste your link here", text: $wishLinkTextField)
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
                            focusedWish = nil
                            wishlistTextField = ""
                            wishLinkTextField = ""
                            withAnimation {
                                wishlistFieldFocused = false
                                linkFieldFocused = false
                                wishHasLink = false
                                showTextFields = false
                            }
                        }
                        .buttonStyle(DepthButtonStyle(backgroundColor: .red))
                        Button("Save") {
                            let newWish = WishListItem(description: wishlistTextField, link: wishLinkTextField)
                            if newWish != focusedWish {
                                onboardingViewModel.wishList.removeAll(where: { $0 == focusedWish })
                                onboardingViewModel.wishList.append(newWish)
                            }
                            focusedWish = nil
                            wishlistTextField = ""
                            wishLinkTextField = ""
                            withAnimation {
                                showTextFields = false
                            }
                        }
                        .buttonStyle(DepthButtonStyle(backgroundColor: .green))
                    }
                    .matchedGeometryEffect(id: "\(wishlistTextField)-WishListButton", in: namespace)
                    .bold()
                }
                .padding(.horizontal)
            } else {
                editableWishList
            }
            Spacer()
        }
        .textFieldStyle(InsetTextFieldStyle(alignment: .leading))
        .buttonStyle(DepthButtonStyle())
        .onChange(of: showTextFields) { _, val in
            withAnimation {
                onboardingViewModel.hideButtons = val
            }
        }
    }
    
    var editableWishList: some View {
        VStack {
            VStack {
                if onboardingViewModel.wishList.isEmpty {
                    Spacer()
                    Text("(nothing yet)")
                    Spacer()
                } else {
                    ScrollView {
                        VStack {
                            ForEach(onboardingViewModel.wishList, id: \.self) { wish in
                                VStack(alignment: .leading) {
                                    Text(wish.description)
                                        .matchedGeometryEffect(id: wish.description, in: namespace)
                                    HStack {
                                        if !wish.link.isEmpty, let url = URL(string: wish.link) {
                                            Link(destination: url) {
                                                HStack(spacing: 5) {
                                                    Text("Link")
                                                        .bold()
                                                        .minimumScaleFactor(0.5)
                                                    Image(.externalLink)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .foregroundStyle(.primary)
                                                }
                                                .frame(maxHeight: 15)
                                                .padding(.horizontal, 2)
                                            }
                                            .allowsTightening(true)
                                            .padding(.trailing, 8)
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
                                                        wishlistFieldFocused = true
                                                        showTextFields = true
                                                    }
                                                }
                                                .buttonStyle(DepthButtonStyle(backgroundColor: .green, shadowRadius: 5))
                                            }
                                            .matchedGeometryEffect(id: wish.description + "-buttons", in: namespace)
                                            .foregroundStyle(Color.black)
                                        } else {
                                            HStack {
                                                Button {
                                                    withAnimation {
                                                        onboardingViewModel.wishList.removeAll(where: { $0 == wish })
                                                        deletedWishes.removeAll(where: { $0 == wish })
                                                    }
                                                } label: {
                                                    Text("Delete")
                                                }
                                                .buttonStyle(DepthButtonStyle(backgroundColor: .red, shadowRadius: 5))
                                                Button("Keep") {
                                                    withAnimation {
                                                        deletedWishes.removeAll(where: { $0 == wish })
                                                    }
                                                }
                                                .buttonStyle(DepthButtonStyle(backgroundColor: .green, shadowRadius: 5))
                                            }
                                            .matchedGeometryEffect(id: wish.description + "-buttons", in: namespace)
                                            .foregroundStyle(Color.black)
                                            Text("Are you sure?")
                                        }
                                    }
                                    .font(.caption)
                                    .matchedGeometryEffect(id: "\(wish.description)-WishListButton", in: namespace)
                                    Divider()
                                        .foregroundStyle(.primary)
                                        .bold()
                                }
                                .padding()
                            }
                        }
                    }
                }
            }
            .fillHorizontally()
            .mainContentBox(material: .ultraThin, padding: 0)
            .padding()
            Button("Add a wish") {
                withAnimation {
                    showTextFields = true
                    wishlistFieldFocused = true
                }
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    OnboardingView<PersonOnboardingViewModel, PersonRepository>(
        items: [
            OnboardWishListView().asAnyView(),
            Text("Second View").asAnyView()
        ],
        onClose: {})
    .background { ShiftingBackground().ignoresSafeArea() }
    .environmentObject(PersonOnboardingViewModel())
}
