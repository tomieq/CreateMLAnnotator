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
    
    init(_ server: HttpServer) {
        var mainTemplate: Template {
            Template(from: "templates/index.html")
        }
        server["/"] = { _, _ in
            let template = mainTemplate
            template.assign(["content": "Welcome to AI label system"])
            return .ok(.html(template.output))
        }
        
        server.notFoundHandler = { request, responseHeaders in
            request.disableKeepAlive = true
            let filePath = Resource().absolutePath(for: request.path)
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
            print("File `\(filePath)` doesn't exist")
            return .notFound()
        }
    }
    
}
