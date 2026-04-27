//
//  UsersViewModelTests.swift
//  NovodaTestTests
//
//  Created by Omer Janjua on 26/04/2026.
//

import XCTest
@testable import NovodaTest

final class UsersViewModelTests: XCTestCase {

    private var sut: UsersViewModel!
    private var touchedUserIDs: Set<Int> = []

    override func setUp() {
        super.setUp()
        sut = UsersViewModel()
        touchedUserIDs = []
    }

    override func tearDown() {
        for userID in touchedUserIDs where FollowManager.shared.isFollowing(userID: userID) {
            FollowManager.shared.toggleFollow(userID: userID)
        }
        touchedUserIDs = []
        sut = nil
        super.tearDown()
    }

    // MARK: - users

    func test_numberOfUsers_isZero_whenInitialisedEmpty() {
        XCTAssertEqual(sut.numberOfUsers(), 0)
    }

    func test_numberOfUsers_reflectsAssignedUsers() {
        sut.users = [makeUser(id: uniqueUserID()), makeUser(id: uniqueUserID())]
        XCTAssertEqual(sut.numberOfUsers(), 2)
    }

    func test_userAt_returnsUserAtIndex() {
        let first = makeUser(id: uniqueUserID(), name: "First")
        let second = makeUser(id: uniqueUserID(), name: "Second")
        sut.users = [first, second]

        XCTAssertEqual(sut.user(at: 0), first)
        XCTAssertEqual(sut.user(at: 1), second)
    }

    func test_userAt_returnsNil_forOutOfBoundsIndex() {
        XCTAssertNil(sut.user(at: 0))

        sut.users = [makeUser(id: uniqueUserID())]
        XCTAssertNil(sut.user(at: 5))
        XCTAssertNil(sut.user(at: -1))
    }

    // MARK: - following

    func test_isFollowing_isFalse_forUntouchedUser() {
        sut.users = [makeUser(id: uniqueUserID())]
        XCTAssertFalse(sut.isFollowing(userAt: 0))
    }

    func test_isFollowing_isFalse_forOutOfBoundsIndex() {
        XCTAssertFalse(sut.isFollowing(userAt: 0))
    }

    func test_toggleFollow_followsThenUnfollows() {
        sut.users = [makeUser(id: uniqueUserID())]

        XCTAssertTrue(sut.toggleFollow(at: 0))
        XCTAssertTrue(sut.isFollowing(userAt: 0))

        XCTAssertFalse(sut.toggleFollow(at: 0))
        XCTAssertFalse(sut.isFollowing(userAt: 0))
    }

    func test_toggleFollow_isIndependentPerUser() {
        sut.users = [
            makeUser(id: uniqueUserID()),
            makeUser(id: uniqueUserID()),
            makeUser(id: uniqueUserID())
        ]

        sut.toggleFollow(at: 0)
        sut.toggleFollow(at: 2)

        XCTAssertTrue(sut.isFollowing(userAt: 0))
        XCTAssertFalse(sut.isFollowing(userAt: 1))
        XCTAssertTrue(sut.isFollowing(userAt: 2))
    }

    func test_toggleFollow_returnsFalse_forOutOfBoundsIndex() {
        XCTAssertFalse(sut.toggleFollow(at: 0))
        XCTAssertFalse(sut.toggleFollow(at: 99))
    }

    // MARK: - helpers

    private func makeUser(id: Int, name: String = "User") -> User {
        User(id: id, rawDisplayName: name, reputation: 100, profileImageURL: nil)
    }

    private func uniqueUserID(line: UInt = #line) -> Int {
        let id = Int.random(in: 0..<100_000)
        touchedUserIDs.insert(id)
        return id
    }
}
