//
//  Encodable+extension.swift
//
//
//  Created by Tomasz on 29/03/2024.
//

import Foundation

extension Encodable {
    var json: String? {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
