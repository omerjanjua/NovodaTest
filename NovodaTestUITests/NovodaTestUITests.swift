//
//  NovodaTestUITests.swift
//  NovodaTestUITests
//
//  Created by Omer Janjua on 26/04/2026.
//

import XCTest

final class NovodaTestUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Launch

    @MainActor
    func test_appLaunches_showsTableView() {
        XCTAssertTrue(app.tables.firstMatch.waitForExistence(timeout: 5),
                      "Expected the users table view to be visible after launch.")
    }

    // MARK: - List rendering

    @MainActor
    func test_usersList_populatesCells_afterFetch() {
        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 5))

        // Wait for the network fetch to populate the table.
        let firstCell = table.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10),
                      "Expected at least one user cell to be displayed.")

        // The spec asks for the top 20 users.
        let predicate = NSPredicate(format: "count >= 20")
        let exp = expectation(for: predicate, evaluatedWith: table.cells)
        wait(for: [exp], timeout: 10)
    }

    @MainActor
    func test_eachCell_displaysNameAndReputation() {
        let table = app.tables.firstMatch
        XCTAssertTrue(table.cells.firstMatch.waitForExistence(timeout: 10))

        let firstCell = table.cells.element(boundBy: 0)
        let staticTexts = firstCell.staticTexts
        // Subtitle cell exposes title (name) and secondary (reputation) as static texts.
        XCTAssertGreaterThanOrEqual(staticTexts.count, 2,
                                    "Expected each cell to show a name and a reputation value.")
        XCTAssertFalse(staticTexts.element(boundBy: 0).label.isEmpty,
                       "Expected the user's display name to be non-empty.")
        XCTAssertFalse(staticTexts.element(boundBy: 1).label.isEmpty,
                       "Expected the user's reputation to be non-empty.")
    }

    // MARK: - Follow / unfollow

    @MainActor
    func test_tappingCell_togglesFollowCheckmark() {
        let table = app.tables.firstMatch
        XCTAssertTrue(table.cells.firstMatch.waitForExistence(timeout: 10))

        let cell = table.cells.element(boundBy: 0)
        let initiallyFollowed = hasCheckmark(cell)

        // Tap to toggle follow state.
        cell.tap()
        let afterFirstTap = hasCheckmark(cell)
        XCTAssertNotEqual(initiallyFollowed, afterFirstTap,
                          "Tapping a cell should toggle its follow checkmark accessory.")

        // Tap again to restore original state (also acts as cleanup).
        cell.tap()
        let afterSecondTap = hasCheckmark(cell)
        XCTAssertEqual(initiallyFollowed, afterSecondTap,
                       "Tapping a followed cell again should remove the checkmark.")
    }

    @MainActor
    func test_followStatus_persistsAcrossRelaunch() {
        let table = app.tables.firstMatch
        XCTAssertTrue(table.cells.firstMatch.waitForExistence(timeout: 10))

        let cell = table.cells.element(boundBy: 0)
        let initiallyFollowed = hasCheckmark(cell)

        // Toggle follow state.
        cell.tap()
        XCTAssertNotEqual(hasCheckmark(cell), initiallyFollowed)

        // Relaunch the app.
        app.terminate()
        app.launch()

        let relaunchedTable = app.tables.firstMatch
        XCTAssertTrue(relaunchedTable.cells.firstMatch.waitForExistence(timeout: 10))
        let relaunchedCell = relaunchedTable.cells.element(boundBy: 0)
        XCTAssertNotEqual(hasCheckmark(relaunchedCell), initiallyFollowed,
                          "Follow status should persist across app launches.")

        // Cleanup: restore original state so the test is idempotent.
        relaunchedCell.tap()
    }

    @MainActor
    func test_followingOneUser_doesNotAffectOtherUsers() {
        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 5))
        let predicate = NSPredicate(format: "count >= 2")
        let exp = expectation(for: predicate, evaluatedWith: table.cells)
        wait(for: [exp], timeout: 10)

        let firstCell = table.cells.element(boundBy: 0)
        let secondCell = table.cells.element(boundBy: 1)

        let firstInitial = hasCheckmark(firstCell)
        let secondInitial = hasCheckmark(secondCell)

        firstCell.tap()
        XCTAssertNotEqual(hasCheckmark(firstCell), firstInitial)
        XCTAssertEqual(hasCheckmark(secondCell), secondInitial,
                       "Following one user must not change another user's follow state.")

        // Cleanup.
        firstCell.tap()
    }

    // MARK: - Helpers

    private func hasCheckmark(_ cell: XCUIElement) -> Bool {
        return cell.images["checkmark"].exists || cell.buttons["checkmark"].exists
    }
}
