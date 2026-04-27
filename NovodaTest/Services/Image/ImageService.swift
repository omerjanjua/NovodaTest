//
//  ImageService.swift
//  NovodaTest
//
//  Created by Omer Janjua on 26/04/2026.
//

import UIKit

final class ImageService: ImageServiceProtocol {

    private let client: HTTPClient
    private let cache: ImageCacheProtocol

    init(client: HTTPClient = URLSession.shared, cache: ImageCacheProtocol = ImageCache()) {
        self.client = client
        self.cache = cache
    }

    func fetchImage(from urlString: String?) async throws -> UIImage {

        guard let unwrappedURL = urlString,
              let url = URL(string: unwrappedURL) else {
            throw ImageError.invalidURL
        }

        if let cached = cache.image(for: unwrappedURL) {
            return cached
        }

        let data: Data
        do {
            (data, _) = try await client.data(from: url)
        } catch {
            throw ImageError.transport
        }

        guard let image = UIImage(data: data) else {
            throw ImageError.invalidData
        }

        cache.insert(image, for: unwrappedURL)
        return image
    }
}
