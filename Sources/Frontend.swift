//
//  Frontend.swift
//
//
//  Created by Tomasz on 29/03/2024.
//

import Foundation
import Swifter
import Template

class Frontend {
    
    let picturesPath = ArgumentParser.getValue("pictures") ?? FileManager.default.currentDirectoryPath
    let descriptor: FolderDescriptor?
    
    init(_ server: HttpServer) {
        print("Loaded pictures from parameter `pictures`: \(self.picturesPath)")
        self.descriptor = FolderDescriptor(folderPath: self.picturesPath)
        var mainTemplate: Template {
            Template(from: "templates/index.html")
        }
        server["/"] = { [weak self] request, _ in
            let template = mainTemplate
            template.assign(["content": "Welcome to AI label system"])
            
            let formData = request.flatFormData()
            if let topTxt = formData["top"], let top = Int(topTxt),
               let leftTxt = formData["left"], let left = Int(leftTxt),
               let widthTxt = formData["width"], let width = Int(widthTxt),
               let heightTxt = formData["height"], let height = Int(heightTxt),
               let filename = formData["filename"], let label = formData["label"] {

                let coordinate = Coordinate(x: top, y: left, width: width, height: height)
                let image = Image(filename: filename, annotations: [Annotation(label: label,
                                                                               coordinates: coordinate)])
                self?.descriptor?.add(image: image)
            }
            return .ok(.html(template.output))
        }
        
        server.notFoundHandler = { request, responseHeaders in
            request.disableKeepAlive = true
            let filePath = Resource().absolutePath(for: request.path)
            if let response = self.serveIfExists(filePath: filePath, responseHeaders: responseHeaders) {
                return response
            }
            let picturePath = self.picturesPath + "/\(request.path)"
            if let response = self.serveIfExists(filePath: picturePath, responseHeaders: responseHeaders) {
                return response
            }
            print("File `\(filePath)` doesn't exist")
            return .notFound()
        }
    }
    
    private func serveIfExists(filePath: String, responseHeaders: HttpResponseHeaders) -> HttpResponse? {
        if FileManager.default.fileExists(atPath: filePath) {
            guard let file = try? filePath.openForReading() else {
                print("Could not open `\(filePath)`")
                return .notFound()
            }
            let mimeType = filePath.mimeType()
            responseHeaders.addHeader("Content-Type", mimeType)

            if let attr = try? FileManager.default.attributesOfItem(atPath: filePath),
               let fileSize = attr[FileAttributeKey.size] as? UInt64 {
                responseHeaders.addHeader("Content-Length", String(fileSize))
            }

            return .raw(200, "OK", { writer in
                try writer.write(file)
                file.close()
            })
        }
        return nil
    }
}
