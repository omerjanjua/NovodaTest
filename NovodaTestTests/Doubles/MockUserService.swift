//
//  MockUserService.swift
//  NovodaTest
//
//  Created by Omer Janjua on 27/04/2026.
//

@testable import NovodaTest

final class MockUserService: UserServiceProtocol {
    var stubbedUsers: [User] = []
    var stubbedError: Error?
    private(set) var fetchUsersCallCount = 0

    func fetchUsers() async throws -> [User] {
        fetchUsersCallCount += 1
        if let stubbedError { throw stubbedError }
        return stubbedUsers
    }
}
