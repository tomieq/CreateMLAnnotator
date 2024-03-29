//
//  Coordinate.swift
//
//
//  Created by Tomasz on 29/03/2024.
//

import Foundation

struct Coordinate: Codable {
    let x: Int
    let y: Int
    let width: Int
    let height: Int
}

extension Coordinate: Equatable {}
