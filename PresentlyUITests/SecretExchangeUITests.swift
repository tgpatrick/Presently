//
//  SecretExchangeUITests.swift
//  PresentlyUITests
//
//  Created by Thomas Patrick on 11/2/23.
//

import XCTest

final class SecretExchangeUITests: BaseTestCase {
    func testExchangeDetailSecret() {
        loginToSecretExchange()
        
        app.buttons["ExchangeDetailButton"].tap()
        
        
        mozWaitForElementToExist(app.staticTexts["Intro"])
        mozWaitForElementToExist(app.staticTexts["IntroText"])
        mozWaitForElementToExist(app.staticTexts["Rules"])
        mozWaitForElementToExist(app.staticTexts["RulesText1"])
        mozWaitForElementToExist(app.staticTexts["RulesText2"])
        mozWaitForElementToExist(app.staticTexts["RulesText3"])
        mozWaitForElementToExist(app.staticTexts["Status"])
        mozWaitForElementToExist(app.staticTexts["Started"])
        mozWaitForElementToExist(app.staticTexts["Assignments have been made. Next step is gift giving!"])
    }
}
