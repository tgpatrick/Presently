//
//  OpenExchangeUITests.swift
//  PresentlyUITests
//
//  Created by Thomas Patrick on 11/2/23.
//

import XCTest

final class OpenExchangeUITests: BaseTestCase {
    func testExchangeDetailOpen() {
        loginToOpenExchange()
        
        app.buttons["ExchangeDetailButton"].tap()
        
        mozWaitForElementToExist(app.staticTexts["Intro"])
        mozWaitForElementToExist(app.staticTexts["IntroText"])
        mozWaitForElementToExist(app.staticTexts["Rules"])
        mozWaitForElementToExist(app.staticTexts["RulesText1"])
        mozWaitForElementToExist(app.staticTexts["RulesText2"])
        mozWaitForElementToExist(app.staticTexts["RulesText3"])
        mozWaitForElementToExist(app.staticTexts["Status"])
        mozWaitForElementToExist(app.staticTexts["Open"])
        mozWaitForElementToExist(app.staticTexts["Assignments have not been made and people can still be added."])
    }
}
