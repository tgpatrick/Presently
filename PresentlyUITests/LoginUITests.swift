//
//  LoginUITests.swift
//  PresentlyUITests
//
//  Created by Thomas Patrick on 10/28/23.
//

import XCTest

final class LoginUITests: BaseTestCase {

    func testLoginElementsExist() throws {
        let logoImage = app.images["logo"]
        let appName = app.staticTexts["Presently"]
        let exchangeField = app.textFields["exchangeIdTextField"]
        let personField = app.textFields["personIdTextField"]
        let loginButton = app.buttons["LoginButton"]
        
        mozWaitForElementToExist(logoImage)
        mozWaitForElementToExist(appName)
        mozWaitForElementToExist(exchangeField)
        mozWaitForElementToExist(personField)
        mozWaitForElementToExist(loginButton)
        
        XCTAssertTrue(logoImage.isAbove(element: appName))
        XCTAssertTrue(appName.isAbove(element: exchangeField))
        XCTAssertTrue(appName.isAbove(element: personField))
        XCTAssertTrue(exchangeField.isLeftOf(rightElement: personField))
        XCTAssertTrue(exchangeField.isAbove(element: loginButton))
    }
    
    func testLoginFail() throws {
        let exchangeField = app.textFields["exchangeIdTextField"]
        let personField = app.textFields["personIdTextField"]
        let loginButton = app.buttons["LoginButton"]
        
        exchangeField.tap()
        exchangeField.typeText("BAD1")
        personField.typeText("CODE")
        loginButton.tap()
        
        mozWaitForElementToExist(app.staticTexts["There was an error logging you in.\nPlease check your code and internet and try again."])
    }
    
    func testLoginSucceed() throws {
        let exchangeField = app.textFields["exchangeIdTextField"]
        let personField = app.textFields["personIdTextField"]
        let loginButton = app.buttons["LoginButton"]
        
        exchangeField.tap()
        exchangeField.typeText("0001")
        personField.typeText("0001")
        loginButton.tap()
        
        mozWaitForElementToExist(app.scrollViews["NavScrollView"])
    }
}
