//
//  Exercise20240328UITests.swift
//  Exercise20240328UITests
//
//  Created by 五泉仁 on 2024/03/28.
//

import XCTest

final class Exercise20240328UITests: XCTestCase {
    func testNavigation() throws {
        let app = XCUIApplication()
        app.launchEnvironment.updateValue("true", forKey: "UITest")
        app.launch()
        
        let users = app.buttons["userRow"]
        XCTAssert(users.waitForExistence(timeout: 3))
        users.firstMatch.tap()
        
        let repos = app.buttons["repoRow"]
        XCTAssert(repos.waitForExistence(timeout: 3))
        repos.firstMatch.tap()
        
        let webView = app.webViews.firstMatch
        XCTAssert(webView.waitForExistence(timeout: 3))
    }
}
