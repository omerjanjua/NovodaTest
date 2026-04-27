//
//  ImageServiceProtocol.swift
//  NovodaTest
//
//  Created by Omer Janjua on 27/04/2026.
//

import UIKit

protocol ImageServiceProtocol {
    func fetchImage(from urlString: String?) async throws -> UIImage
}
