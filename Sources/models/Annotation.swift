//
//  Annotation.swift
//
//
//  Created by Tomasz on 29/03/2024.
//

import Foundation

class Annotation: Codable {
    var label: String
    let coordinates: Coordinate
    
    init(label: String, coordinates: Coordinate) {
        self.label = label
        self.coordinates = coordinates
    }
}

