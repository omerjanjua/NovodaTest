//
//  ImageServiceTests.swift
//  NovodaTestTests
//
//  Created by Omer Janjua on 26/04/2026.
//

import XCTest
import UIKit
@testable import NovodaTest

private final class MemoryCache: ImageCacheProtocol {
    private(set) var storage: [String: UIImage] = [:]
    func image(for key: String) -> UIImage? { storage[key] }
    func insert(_ image: UIImage, for key: String) { storage[key] = image }
}

final class ImageServiceTests: XCTestCase {

    private var session: URLSession!
    private var cache: MemoryCache!
    private let imageURLString = "https://img/a.png"

    override func setUp() {
        super.setUp()
        session = URLSession.mocked()
        cache = MemoryCache()
    }

    override func tearDown() {
        MockURLProtocol.reset()
        session = nil
        cache = nil
        super.tearDown()
    }

    func test_returnsImage_andCachesIt_onSuccess() async throws {
        let pngData = Self.makePNG()

        var calls = 0
        MockURLProtocol.requestHandler = { request in
            calls += 1
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, pngData)
        }

        let sut = await ImageService(client: session, cache: cache)

        _ = try await sut.fetchImage(from: imageURLString)
        XCTAssertEqual(cache.storage.count, 1)
        XCTAssertNotNil(cache.storage[imageURLString])

        // Second call should be served from cache (no extra network hit).
        _ = try await sut.fetchImage(from: imageURLString)
        XCTAssertEqual(calls, 1)
    }

    func test_throwsInvalidURL_whenURLIsNil() async {
        let sut = await ImageService(client: session, cache: cache)
        do {
            _ = try await sut.fetchImage(from: nil)
            XCTFail("Expected invalidURL")
        } catch ImageError.invalidURL {
            // success
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func test_throwsInvalidData_whenBytesAreNotImage() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data("not an image".utf8))
        }
        let sut = await ImageService(client: session, cache: cache)
        do {
            _ = try await sut.fetchImage(from: imageURLString)
            XCTFail("Expected invalidData")
        } catch ImageError.invalidData {
            // success
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func test_throwsTransport_onNetworkFailure() async {
        MockURLProtocol.requestHandler = { _ in throw URLError(.timedOut) }
        let sut = await ImageService(client: session, cache: cache)
        do {
            _ = try await sut.fetchImage(from: imageURLString)
            XCTFail("Expected transport")
        } catch ImageError.transport {
            // success
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    // MARK: - helpers

    private static func makePNG() -> Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        let image = renderer.image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        return image.pngData()!
    }
}
