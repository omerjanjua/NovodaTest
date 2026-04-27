//
//  APIError.swift
//  NovodaTest
//
//  Created by Omer Janjua on 27/04/2026.
//

enum APIError: Error, Equatable {
    case invalidURL
    case requestFailed(Int)
    case decodingFailed
    case transport
}
