//
//  FolderDescriptor.swift
//
//
//  Created by Tomasz on 29/03/2024.
//

import Foundation

class FolderDescriptor {
    private let folderPath: String
    private let descriptorUrl: URL
    private var images: [Image] = []
    
    init?(folderPath: String) {
        self.folderPath = folderPath
        guard FileManager.default.fileExists(atPath: folderPath) else { return nil }
        self.descriptorUrl = URL(fileURLWithPath: self.folderPath + "/annotations.json")
        if let data = try? Data(contentsOf: self.descriptorUrl), let images = [Image](json: data) {
            self.images = images
        }
    }
    
    func add(image: Image) {
        if let existingImage = (self.images.first { $0.filename == image.filename }) {
            existingImage.annotations.append(contentsOf: image.annotations)
        } else {
            self.images.append(image)
        }
        self.save()
    }
    
    func save() {
        if let json = self.images.json {
            try? json.write(to: descriptorUrl, atomically: false, encoding: .utf8)
        }
    }
}
