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
    let converter = DataConverter()
    
    init(_ server: HttpServer) {
        print("Loaded pictures from parameter `pictures`: \(self.picturesPath)")
        self.descriptor = FolderDescriptor(folderPath: self.picturesPath)
        var mainTemplate: Template {
            Template.cahed(from: "templates/index.html")
        }
        server["/"] = { [weak self] request, _ in
            let template = mainTemplate
            let listTemplate = Template(from: "templates/list.tpl.html")
            self?.descriptor?.filenames.forEach {
                listTemplate.assign(["filename": $0], inNest: "link")
            }
            template.assign("content", listTemplate.output)
            return .ok(.html(template.output))
        }
        
        server["/previous"] = { [weak self] request, _ in
            guard let filename = request.queryParam("to") else { return .badRequest() }
            guard let previousFile = self?.descriptor?.previousFile(to: filename) else { return .movedTemporarily("/") }
            return .movedTemporarily("/file?name=\(previousFile)")
        }
        
        server["/next"] = { [weak self] request, _ in
            guard let filename = request.queryParam("to") else { return .badRequest() }
            guard let nextFile = self?.descriptor?.nextFile(to: filename) else { return .movedTemporarily("/") }
            return .movedTemporarily("/file?name=\(nextFile)")
        }
        
        server["/remove"] = { [unowned self] request, _ in
            guard let filename = request.queryParam("file") else { return .badRequest() }
            try? FileManager.default.removeItem(atPath: self.picturesPath + "/\(filename)")
            guard let nextFile = self.descriptor?.nextFile(to: filename) else { return .movedTemporarily("/")}
            self.descriptor?.reloadFiles()
            return .movedTemporarily("/file?name=\(nextFile)")
        }
        
        server["/file"] = { [unowned self] request, _ in
            guard let filename = request.queryParam("name") else {
                return .badRequest()
            }
            guard FileManager.default.fileExists(atPath: self.picturesPath + "/\(filename)") else {
                return .notFound()
            }

            let formData = request.flatFormData()
            if let frameJson = formData["frame"], let frame = Frame(json: frameJson),
               let filename = formData["filename"], let label = formData["label"] {

                let coordinate = self.converter.uiToCreateML(frame: frame)
                let image = Image(filename: filename, annotations: [Annotation(label: label,
                                                                               coordinates: coordinate)])
                self.descriptor?.add(image: image)
            }

            let template = mainTemplate
            let picTemplate = Template(from: "templates/picture.tpl.html")
            picTemplate.assign("filename", filename)
            template.assign(["filename": filename], inNest: "script")
            
            var counter = 0
            self.descriptor?.annotationsFor(filename: filename).forEach {
                counter += 1
                let frame = self.converter.createMLToUI(coordinate: $0.coordinates)
                picTemplate.assign(["left" : frame.left,
                                    "top": frame.top,
                                    "width": frame.width,
                                    "height": frame.height,
                                    "counter": counter], inNest: "frame")
                picTemplate.assign(["frame" : frame.jsonOneLine!,
                                    "filename": filename,
                                    "label": $0.label,
                                    "counter": counter], inNest: "form")
            }
            template.assign("content", picTemplate.output)
            

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
