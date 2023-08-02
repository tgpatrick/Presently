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
    year: 2021,
    secret: false,
    repeating: true,
    started: true,
    yearsWithoutRepeat: 0)

var testPeople = [
    testPerson, testPerson2, testPerson3, testPerson4, testPerson5
]

var testPerson = Person(
    id: "0001",
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
    id: "0002",
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
    id: "0003",
    name: "Tes3 McTes3son",
    setUp: false,
    giftHistory: [],
    exceptions: [],
    wishList: [],
    recipient: "",
    organizer: false)
var testPerson4 = Person(
    id: "0004",
    name: "Tes4 McTes4son",
    setUp: false,
    giftHistory: [],
    exceptions: [],
    wishList: [],
    recipient: "",
    organizer: false)
var testPerson5 = Person(
    id: "0005",
    name: "Tes5 McTes5son",
    setUp: false,
    giftHistory: [],
    exceptions: [],
    wishList: [],
    recipient: "",
    organizer: false)
