//
//  MockImageService.swift
//  NovodaTest
//
//  Created by Omer Janjua on 27/04/2026.
//

import UIKit
@testable import NovodaTest

final class MockImageService: ImageServiceProtocol {
    var stubbedImage: UIImage = UIImage()
    var stubbedError: Error?
    private(set) var receivedURLStrings: [String?] = []

    func fetchImage(from urlString: String?) async throws -> UIImage {
        receivedURLStrings.append(urlString)
        if let stubbedError { throw stubbedError }
        return stubbedImage
    }
}
