//
//  PresentlyUITests.swift
//  PresentlyUITests
//
//  Created by Thomas Patrick on 8/1/23.
//  The XCUIElement extensions and functions beginning with "moz" were sourced from the Firefox UI tests:
//  https://github.com/mozilla-mobile/firefox-ios/blob/08a8e1dc031b5f92132dacc935692f9d2a141282/Tests/XCUITests/BaseTestCase.swift#L73
//

import XCTest

let TIMEOUT: TimeInterval = 15
let TIMEOUT_LONG: TimeInterval = 45

class BaseTestCase: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    func restart(_ app: XCUIApplication, args: [String] = []) {
        XCUIDevice.shared.press(.home)
        app.activate()
    }
    
    func mozWaitForElementToExist(_ element: XCUIElement, timeout: TimeInterval? = TIMEOUT) {
        let startTime = Date()
        
        while !element.exists {
            if let timeout = timeout, Date().timeIntervalSince(startTime) > timeout {
                XCTFail("Timed out waiting for element \(element) to exist")
                break
            }
            usleep(10000)
        }
    }
    
    func mozWaitForElementToNotExist(_ element: XCUIElement, timeout: TimeInterval? = TIMEOUT) {
        let startTime = Date()
        
        while element.exists {
            if let timeout = timeout, Date().timeIntervalSince(startTime) > timeout {
                XCTFail("Timed out waiting for element \(element) to not exist")
                break
            }
            usleep(10000)
        }
    }
    
    func mozWaitForValueContains(_ element: XCUIElement, value: String, timeout: TimeInterval? = TIMEOUT) {
        let startTime = Date()
        
        while true {
            if let elementValue = element.value as? String, elementValue.contains(value) {
                break
            } else if let timeout = timeout, Date().timeIntervalSince(startTime) > timeout {
                XCTFail("Timed out waiting for element \(element) to contain value \(value)")
                break
            }
            usleep(10000) // waits for 0.01 seconds
        }
    }
}

extension XCUIElement {
    /// Check the position of one XCUIElement is on the left side of another XCUIElement
    func isLeftOf(rightElement: XCUIElement) -> Bool {
        return self.frame.origin.x < rightElement.frame.origin.x
    }
    
    /// Check the position of one XCUIElement is on the right side of another XCUIElement
    func isRightOf(rightElement: XCUIElement) -> Bool {
        return self.frame.origin.x > rightElement.frame.origin.x
    }
    
    /// Check the position of two XCUIElement objects on vertical line
    /// - parameter element: XCUIElement
    /// - distance: the max distance accepted between them
    /// - return Bool: if the current object is above the given object
    func isAbove(element: XCUIElement, maxDistanceBetween: CGFloat = 700) -> Bool {
        let isAbove = self.frame.origin.y < element.frame.origin.y
        let actualDistance = abs(self.frame.origin.y - element.frame.origin.y)
        return isAbove && (actualDistance < maxDistanceBetween)
    }
    
    /// Check the position of two XCUIElement objects on vertical line
    /// - parameter element: XCUIElement
    /// - distance: the max distance accepted between them
    /// - return Bool: if the current object is below the given object
    func isBelow(element: XCUIElement, maxDistanceBetween: CGFloat = 700) -> Bool {
        let isBelow = self.frame.origin.y > element.frame.origin.y
        let actualDistance = abs(self.frame.origin.y - element.frame.origin.y)
        return isBelow && (actualDistance < maxDistanceBetween)
    }
}
