//
//  HTTPClient.swift
//  NovodaTest
//
//  Created by Omer Janjua on 26/04/2026.
//

import Foundation

protocol HTTPClient {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPClient {}
