//
//  ImageService.swift
//  NovodaTest
//
//  Created by Omer Janjua on 26/04/2026.
//

import UIKit

actor ImageCache {
    static let shared = ImageCache()
    private var cache: [String: UIImage] = [:]
    
    func image(for urlString: String) -> UIImage? {
        return cache[urlString]
    }
    
    func insertImage(_ image: UIImage, for urlString: String) {
        cache[urlString] = image
    }
}

enum ImageError: Error {
    case invalidURL
    case invalidData
}

protocol ImageServiceProtocol {
    func fetchImage(from urlString: String) async throws -> UIImage
}

final class ImageService: ImageServiceProtocol {
    func fetchImage(from urlString: String) async throws -> UIImage {
        // Check cache first
        if let cached = await ImageCache.shared.image(for: urlString) {
            return cached
        }
        
        guard let url = URL(string: urlString) else {
            throw ImageError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = UIImage(data: data) else {
            throw ImageError.invalidData
        }
        
        await ImageCache.shared.insertImage(image, for: urlString)
        return image
    }

}
