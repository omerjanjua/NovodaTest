//
//  UsersViewModelTests.swift
//  NovodaTestTests
//
//  Created by Omer Janjua on 26/04/2026.
//

import XCTest
import UIKit
@testable import NovodaTest

@MainActor
final class UsersViewModelTests: XCTestCase {

    private var sut: UsersViewModel!
    private var userService: MockUserService!
    private var imageService: MockImageService!
    private var touchedUserIDs: Set<Int> = []

    override func setUp() {
        super.setUp()
        userService = MockUserService()
        imageService = MockImageService()
        sut = UsersViewModel(userService: userService, imageService: imageService)
        touchedUserIDs = []
    }

    override func tearDown() {
        for userID in touchedUserIDs where FollowManager.shared.isFollowing(userID: userID) {
            FollowManager.shared.toggleFollow(userID: userID)
        }
        touchedUserIDs = []
        sut = nil
        userService = nil
        imageService = nil
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

    // MARK: - fetchUsers

    func test_fetchUsers_callsService_andStoresResult() async throws {
        let expected = [makeUser(id: uniqueUserID(), name: "A"),
                        makeUser(id: uniqueUserID(), name: "B")]
        userService.stubbedUsers = expected

        let returned = try await sut.fetchUsers()

        XCTAssertEqual(userService.fetchUsersCallCount, 1)
        XCTAssertEqual(returned, expected)
        XCTAssertEqual(sut.users, expected)
        XCTAssertEqual(sut.numberOfUsers(), 2)
    }

    func test_fetchUsers_propagatesError_andDoesNotMutateUsers() async {
        sut.users = [makeUser(id: uniqueUserID(), name: "Existing")]
        userService.stubbedError = APIError.requestFailed(500)

        do {
            _ = try await sut.fetchUsers()
            XCTFail("Expected fetchUsers to throw")
        } catch {
            XCTAssertEqual(error as? APIError, .requestFailed(500))
        }

        XCTAssertEqual(sut.numberOfUsers(), 1, "Existing users should be untouched on failure.")
    }

    // MARK: - fetchImage

    func test_fetchImage_forUser_callsImageServiceWithProfileURL() async throws {
        let user = makeUser(id: uniqueUserID(), profileImageURL: "https://img/example.png")
        let stub = UIImage(systemName: "person")!
        imageService.stubbedImage = stub

        let returned = try await sut.fetchImage(for: user)

        XCTAssertEqual(imageService.receivedURLStrings, ["https://img/example.png"])
        XCTAssertEqual(returned.pngData(), stub.pngData())
    }

    func test_fetchImage_propagatesError() async {
        let user = makeUser(id: uniqueUserID(), profileImageURL: nil)
        imageService.stubbedError = ImageError.invalidURL

        do {
            _ = try await sut.fetchImage(for: user)
            XCTFail("Expected fetchImage to throw")
        } catch {
            XCTAssertEqual(error as? ImageError, .invalidURL)
        }
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

    private func makeUser(id: Int,
                          name: String = "User",
                          profileImageURL: String? = nil) -> User {
        User(id: id, rawDisplayName: name, reputation: 100, profileImageURL: profileImageURL)
    }

    private func uniqueUserID() -> Int {
        let id = Int.random(in: 0..<100_000)
        touchedUserIDs.insert(id)
        return id
    }
}
