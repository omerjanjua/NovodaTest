//
//  UserService.swift
//  NovodaTest
//
//  Created by Omer Janjua on 26/04/2026.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed(Int)
    case decodingFailed
    case noData
}

protocol UserServiceProtocol {
    func fetchUsers() async throws -> [User]
}

final class UserService: UserServiceProtocol {
    private let baseURL = "http://api.stackexchange.com/2.2/users?page=1&pagesize=20&order=desc&sort=reputation&site=stackoverflow"
    
    func fetchUsers() async throws -> [User] {
        
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        
        do {
            let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
            return userResponse.items
        } catch {
            throw APIError.decodingFailed
        }
    }
}
