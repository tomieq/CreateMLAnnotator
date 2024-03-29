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
            guard let coordinates = image.annotations.first?.coordinates else { return }
            if let annotation = (existingImage.annotations.first { $0.coordinates == coordinates}) {
                annotation.label = image.annotations.first!.label
            } else {
                existingImage.annotations.append(contentsOf: image.annotations)
            }
        } else {
            self.images.append(image)
        }
        self.save()
    }
    
    func annotationsFor(filename: String) -> [Annotation] {
        guard let image = (self.images.first { $0.filename == filename } ) else {
            return []
        }
        return image.annotations
    }
    
    func save() {
        if let json = self.images.json {
            try? json.write(to: descriptorUrl, atomically: false, encoding: .utf8)
        }
    }
}
