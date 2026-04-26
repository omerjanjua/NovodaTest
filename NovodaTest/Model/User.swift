//
//  User.swift
//  NovodaTest
//
//  Created by Omer Janjua on 26/04/2026.
//

import Foundation

struct User: Decodable {
    let id: Int
    let rawDisplayName: String
    let reputation: Int
    let profileImageURL: String
    
    var displayName: String {
        rawDisplayName.decodedHTMLEntities
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case rawDisplayName = "display_name"
        case reputation
        case profileImageURL = "profile_image"
    }
}
