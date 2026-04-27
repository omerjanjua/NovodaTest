//
//  UserServiceTests.swift
//  NovodaTestTests
//
//  Created by Omer Janjua on 26/04/2026.
//

import XCTest
@testable import NovodaTest

@MainActor
final class UserServiceTests: XCTestCase {

    private var session: URLSession!
    private let url = "https://example.com/users"

    override func setUp() {
        super.setUp()
        session = URLSession.mocked()
    }

    override func tearDown() {
        MockURLProtocol.reset()
        session = nil
        super.tearDown()
    }

    // MARK: -

    func test_fetchUsers_returnsDecodedUsers_on200() async throws {
        let json = """
        { "items": [
            { "user_id": 1, "display_name": "Jon Skeet", "reputation": 1000, "profile_image": "https://img/1" },
            { "user_id": 2, "display_name": "Gordon &amp; Tonic", "reputation": 50, "profile_image": null }
        ]}
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, self.url)
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let sut = UserService(client: session, urlString: url)
        let users = try await sut.fetchUsers()

        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[0].id, 1)
        XCTAssertEqual(users[0].displayName, "Jon Skeet")
        XCTAssertEqual(users[0].profileImageURL, "https://img/1")
        XCTAssertNil(users[1].profileImageURL)
        // HTML entities are decoded for display.
        XCTAssertEqual(users[1].displayName, "Gordon & Tonic")
    }

    func test_fetchUsers_throwsRequestFailed_onNon2xx() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 503, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let sut = UserService(client: session, urlString: url)
        await assertThrows(APIError.requestFailed(503)) {
            _ = try await sut.fetchUsers()
        }
    }

    func test_fetchUsers_throwsDecodingFailed_onMalformedJSON() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data("not json".utf8))
        }

        let sut = UserService(client: session, urlString: url)
        await assertThrows(APIError.decodingFailed) {
            _ = try await sut.fetchUsers()
        }
    }

    func test_fetchUsers_throwsTransport_onNetworkError() async {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        let sut = UserService(client: session, urlString: url)
        await assertThrows(APIError.transport) {
            _ = try await sut.fetchUsers()
        }
    }

    func test_fetchUsers_throwsInvalidURL_whenURLStringMalformed() async {
        let sut = UserService(client: session, urlString: "")
        await assertThrows(APIError.invalidURL) {
            _ = try await sut.fetchUsers()
        }
    }

    // MARK: - helpers

    private func assertThrows(
        _ expected: APIError,
        _ block: () async throws -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            try await block()
            XCTFail("Expected \(expected) to be thrown", file: file, line: line)
        } catch let error as APIError {
            XCTAssertEqual(error, expected, file: file, line: line)
        } catch {
            XCTFail("Expected APIError.\(expected), got \(error)", file: file, line: line)
        }
    }
}
