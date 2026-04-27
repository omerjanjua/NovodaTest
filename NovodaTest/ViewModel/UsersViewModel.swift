//
//  UsersViewModel.swift
//  NovodaTest
//
//  Created by Omer Janjua on 26/04/2026.
//

import Foundation

final class UsersViewModel {

    var users: [User]

    private let followManager: FollowManager

    init(users: [User] = [], followManager: FollowManager = .shared) {
        self.users = users
        self.followManager = followManager
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
