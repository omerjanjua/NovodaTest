//
//  UsersViewModel.swift
//  NovodaTest
//
//  Created by Omer Janjua on 26/04/2026.
//

import UIKit

final class UsersViewModel {

    var users: [User]

    private let userService: UserServiceProtocol
    private let imageService: ImageServiceProtocol
    private let followManager: FollowManager

    init(
        users: [User] = [],
        userService: UserServiceProtocol = UserService(),
        imageService: ImageServiceProtocol = ImageService(),
        followManager: FollowManager = .shared
    ) {
        self.users = users
        self.userService = userService
        self.imageService = imageService
        self.followManager = followManager
    }

    @discardableResult
    func fetchUsers() async throws -> [User] {
        let fetched = try await userService.fetchUsers()
        users = fetched
        return fetched
    }

    func fetchImage(for user: User) async throws -> UIImage {
        try await imageService.fetchImage(from: user.profileImageURL)
    }

    // MARK: - Users

    func numberOfUsers() -> Int {
        users.count
    }

    func user(at index: Int) -> User? {
        guard users.indices.contains(index) else { return nil }
        return users[index]
    }

    // MARK: - Following

    func isFollowing(userAt index: Int) -> Bool {
        guard let user = user(at: index) else { return false }
        return followManager.isFollowing(userID: user.id)
    }

    @discardableResult
    func toggleFollow(at index: Int) -> Bool {
        guard let user = user(at: index) else { return false }
        followManager.toggleFollow(userID: user.id)
        return followManager.isFollowing(userID: user.id)
    }
}
