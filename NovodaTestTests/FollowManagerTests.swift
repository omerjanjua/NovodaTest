//
//  FollowManagerTests.swift
//  NovodaTestTests
//
//  Created by Omer Janjua on 26/04/2026.
//

import XCTest
@testable import NovodaTest

final class FollowManagerTests: XCTestCase {

    private let userDefaultsKey = "followedUserIDs"
    private var sut: FollowManager!
    private var touchedUserIDs: Set<Int> = []

    override func setUp() {
        super.setUp()
        sut = FollowManager.shared
        touchedUserIDs = []
    }

    override func tearDown() {
        for userID in touchedUserIDs where sut.isFollowing(userID: userID) {
            sut.toggleFollow(userID: userID)
        }
        touchedUserIDs = []
        sut = nil
        super.tearDown()
    }

    func test_isFollowing_isFalseForUntouchedUser() {
        let userID = uniqueUserID()
        XCTAssertFalse(sut.isFollowing(userID: userID))
    }

    func test_toggleFollow_followsThenUnfollows() {
        let userID = uniqueUserID()

        sut.toggleFollow(userID: userID)
        XCTAssertTrue(sut.isFollowing(userID: userID))

        sut.toggleFollow(userID: userID)
        XCTAssertFalse(sut.isFollowing(userID: userID))
    }

    func test_toggleFollow_isIndependentPerUser() {
        let firstID = uniqueUserID()
        let secondID = uniqueUserID()
        let untouchedID = uniqueUserID()

        sut.toggleFollow(userID: firstID)
        sut.toggleFollow(userID: secondID)

        XCTAssertTrue(sut.isFollowing(userID: firstID))
        XCTAssertTrue(sut.isFollowing(userID: secondID))
        XCTAssertFalse(sut.isFollowing(userID: untouchedID))
    }

    func test_toggleFollow_writesToUserDefaults() {
        let userID = uniqueUserID()
        sut.toggleFollow(userID: userID)

        let stored = UserDefaults.standard.array(forKey: userDefaultsKey) as? [Int] ?? []
        XCTAssertTrue(stored.contains(userID),
                      "Expected UserDefaults to contain \(userID) after follow, got \(stored)")
    }

    func test_unfollow_removesUserFromUserDefaults() {
        let userID = uniqueUserID()

        sut.toggleFollow(userID: userID) // follow
        sut.toggleFollow(userID: userID) // unfollow

        let stored = UserDefaults.standard.array(forKey: userDefaultsKey) as? [Int] ?? []
        XCTAssertFalse(stored.contains(userID),
                       "Expected UserDefaults to no longer contain \(userID) after unfollow")
    }

    func test_shared_returnsTheSameInstance() {
        XCTAssertTrue(FollowManager.shared === FollowManager.shared)
    }

    // MARK: - helpers

    private func uniqueUserID(line: UInt = #line) -> Int {
        let id = Int.random(in: 0..<100_000)
        touchedUserIDs.insert(id)
        return id
    }
}
