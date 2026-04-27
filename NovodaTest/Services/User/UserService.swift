//
//  UserService.swift
//  NovodaTest
//
//  Created by Omer Janjua on 26/04/2026.
//

import Foundation

final class UserService: UserServiceProtocol {

    private let client: HTTPClient
    private let urlString: String
    private let decoder: JSONDecoder

    init(
        client: HTTPClient = URLSession.shared,
        urlString: String = "http://api.stackexchange.com/2.2/users?page=1&pagesize=20&order=desc&sort=reputation&site=stackoverflow",
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.client = client
        self.urlString = urlString
        self.decoder = decoder
    }

    func fetchUsers() async throws -> [User] {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await client.data(from: url)
        } catch {
            throw APIError.transport
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.requestFailed(-1)
        }
        guard (200...299).contains(http.statusCode) else {
            throw APIError.requestFailed(http.statusCode)
        }

        do {
            return try decoder.decode(UserResponse.self, from: data).items
        } catch {
            throw APIError.decodingFailed
        }
    }
}
