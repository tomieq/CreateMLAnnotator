//
//  Image.swift
//
//
//  Created by Tomasz on 29/03/2024.
//

import Foundation

class Image: Codable {
    let filename: String
    var annotations: [Annotation]
    
    init(filename: String, annotations: [Annotation]) {
        self.filename = filename
        self.annotations = annotations
    }
    
    enum CodingKeys: String, CodingKey {
        case filename = "image"
        case annotations
    }
}
