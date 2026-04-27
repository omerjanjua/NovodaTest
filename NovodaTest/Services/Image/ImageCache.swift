//
//  ImageCache.swift
//  NovodaTest
//
//  Created by Omer Janjua on 27/04/2026.
//

import UIKit

final class ImageCache: ImageCacheProtocol{
    private let cache = NSCache<NSString, UIImage>()

    func image(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func insert(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
