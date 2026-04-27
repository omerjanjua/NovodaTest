//
//  String+DecodedHTMLEntities.swift
//  NovodaTest
//
//  Created by Omer Janjua on 26/04/2026.
//

import UIKit

extension String {
    
    /**
     NSAttributedString is not very light weight. For performance reasons it's better to cache this when displaying on UI. But for the purpose of this exercise since it only requires to display 20 items it is ok.
     */    
    var decodedHTMLEntities: String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributed.string
        }
        return self
    }
}
