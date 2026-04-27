//
//  ImageCacheProtocol.swift
//  NovodaTest
//
//  Created by Omer Janjua on 27/04/2026.
//

import UIKit

protocol ImageCacheProtocol: AnyObject {
    func image(for key: String) -> UIImage?
    func insert(_ image: UIImage, for key: String)
}
