//
//  FollowManager.swift
//  NovodaTest
//
//  Created by Omer Janjua on 27/04/2026.
//

import Foundation

final class FollowManager {
    static let shared = FollowManager()
    private let userDefaultsKey = "followedUserIDs"
    private var followedUserIDs: Set<Int>
    
    private init() {
        let loaded = UserDefaults.standard.array(forKey: userDefaultsKey) as? [Int] ?? []
        followedUserIDs = Set(loaded)
    }
    
    func isFollowing(userID: Int) -> Bool {
        followedUserIDs.contains(userID)
    }
    
    func toggleFollow(userID: Int) {
        if isFollowing(userID: userID) {
            followedUserIDs.remove(userID)
        } else {
            followedUserIDs.insert(userID)
        }
        save()
    }
    
    private func save() {
        UserDefaults.standard.set(Array(followedUserIDs), forKey: userDefaultsKey)
    }
}
