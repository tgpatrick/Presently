//
//  TestFiles.swift
//  GiftHub
//
//  Created by Thomas Patrick on 11/12/21.
//

import Foundation

var testExchange = Exchange(
    id: "0001",
    name: "Test Exchange",
    intro: "Welcome to the test exchange! You must be special to have gotten a code to this one.",
    rules: "There are NO RULES. Spend a billion dollars per gift, see if I care.",
    startDate: Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date(),
    assignDate: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()),
    theBigDay: Calendar.current.date(byAdding: .weekOfYear, value: 4, to: Date()),
    year: 2021,
    secret: false,
    repeating: true,
    started: true,
    yearsWithoutRepeat: 0)

var testPeople = [
    testPerson, testPerson2, testPerson3, testPerson4, testPerson5
]

var testPerson = Person(
    exchangeId: "0001",
    personId: "0001",
    name: "Tester McTesterson",
    setUp: false,
    giftHistory: [
        HistoricalGift(year: 2020, recipientId: "0002", description: "Bag of four grapes"),
        HistoricalGift(year: 2019, recipientId: "0003", description: "Bag of three grapes"),
        HistoricalGift(year: 2018, recipientId: "0004", description: "Bag of two grapes")
    ],
    exceptions: [
        "0003",
        "0004",
        "0005"
    ],
    wishList: [
        WishListItem(description: "All I want for Christmas is you", link: ""),
        WishListItem(description: "Well, also an Italian visa", link: "https://www.google.com")
    ],
    recipient: "0002",
    organizer: true)
var testPerson2 = Person(
    exchangeId: "0001",
    personId: "0002",
    name: "Tes2 McTes2son",
    setUp: false,
    giftHistory: [],
    exceptions: [
        "0003",
        "0004",
        "0005"
    ],
    wishList: [
        WishListItem(description: "I want Amazon.", link: "https://www.amazon.com"),
        WishListItem(description: "I want Google.", link: "https://www.google.com"),
        WishListItem(description: "I want Apple.", link: "https://www.apple.com"),
        WishListItem(description: "I want the world.", link: "")
    ],
    recipient: "",
    organizer: false)
var testPerson3 = Person(
    exchangeId: "0001",
    personId: "0003",
    name: "Tes3 McTes3son",
    setUp: false,
    giftHistory: [],
    exceptions: [],
    wishList: [],
    recipient: "",
    organizer: false)
var testPerson4 = Person(
    exchangeId: "0001",
    personId: "0004",
    name: "Tes4 McTes4son",
    setUp: false,
    giftHistory: [],
    exceptions: [],
    wishList: [],
    recipient: "",
    organizer: false)
var testPerson5 = Person(
    exchangeId: "0001",
    personId: "0005",
    name: "Tes5 McTes5son",
    setUp: false,
    giftHistory: [],
    exceptions: [],
    wishList: [],
    recipient: "",
    organizer: false)
