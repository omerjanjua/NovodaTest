//
//  UserServiceProtocol.swift
//  NovodaTest
//
//  Created by Omer Janjua on 27/04/2026.
//

protocol UserServiceProtocol {
    func fetchUsers() async throws -> [User]
}
