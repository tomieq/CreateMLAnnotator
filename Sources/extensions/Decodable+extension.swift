//
//  Decodable+extension.swift
//
//
//  Created by Tomasz on 29/03/2024.
//

import Foundation

extension Decodable {

    init?(json: Data) {
        let decoder = JSONDecoder()
        do {
            self = try decoder.decode(Self.self, from: json)
        } catch {
            print("json error: \(error)")
            return nil
        }
    }
}
