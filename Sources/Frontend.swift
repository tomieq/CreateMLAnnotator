//
//  Frontend.swift
//
//
//  Created by Tomasz on 29/03/2024.
//

import Foundation
import Swifter
import BootstrapTemplate
import Template
import Env

class Frontend {
    
    let picturesPath = Env().get("folder") ?? FileManager.default.currentDirectoryPath
    let descriptor: FolderDescriptor?
    let converter = DataConverter()
    
    init(_ server: HttpServer) {
        print("Loaded pictures from parameter `pictures`: \(self.picturesPath)")
        self.descriptor = FolderDescriptor(folderPath: self.picturesPath)
        
        func wrapTemplate(_ content: CustomStringConvertible) -> BootstrapTemplate {
            let main = BootstrapTemplate()
            main.body = content
            main.addCSS(url: "style.css")
            return main
        }

        var pageTemplate: Template {
            Template.cached(relativePath: "templates/index.html")
        }
        
        server["/"] = { [weak self] request, _ in

            let listTemplate = Template.cached(relativePath: "templates/list.tpl.html")
            self?.descriptor?.filenames.forEach {
                listTemplate.assign(["filename": $0], inNest: "link")
            }
            let template = pageTemplate
            template["content"] = listTemplate
            return .ok(.html(wrapTemplate(template)))
        }
        
        server.get["editor.js"] = { request, _ in
            let js = Template.cached(relativePath: "templates/editor.tpl.js")
            js["filename"] = request.queryParams.get("filename")
            return .ok(.js(js))
        }
        
        server["/previous"] = { [weak self] request, _ in
            guard let filename = request.queryParams.get("to") else { return .badRequest() }
            guard let previousFile = self?.descriptor?.previousFile(to: filename) else { return .movedTemporarily("/") }
            return .movedTemporarily("/file?name=\(previousFile)")
        }
        
        server["/next"] = { [weak self] request, _ in
            guard let filename = request.queryParams.get("to") else { return .badRequest() }
            guard let nextFile = self?.descriptor?.nextFile(to: filename) else { return .movedTemporarily("/") }
            return .movedTemporarily("/file?name=\(nextFile)")
        }
        
        server["/remove"] = { [unowned self] request, _ in
            guard let filename = request.queryParams.get("file") else { return .badRequest() }
            try? FileManager.default.removeItem(atPath: self.picturesPath + "/\(filename)")
            guard let nextFile = self.descriptor?.nextFile(to: filename) else { return .movedTemporarily("/")}
            self.descriptor?.reloadFiles()
            return .movedTemporarily("/file?name=\(nextFile)")
        }
        
        server["/file"] = { [unowned self] request, _ in
            guard let filename = request.queryParams.get("name") else {
                return .badRequest()
            }
            guard FileManager.default.fileExists(atPath: self.picturesPath + "/\(filename)") else {
                return .notFound()
            }
            struct Input: Codable {
                let frame: String
                let label: String
            }
            let input: Input = try request.formData.decode()
            if let frame = Frame(json: input.frame) {

                let coordinate = self.converter.uiToCreateML(frame: frame)
                let image = Image(filename: filename, annotations: [Annotation(label: input.label,
                                                                               coordinates: coordinate)])
                self.descriptor?.add(image: image)
            }
            let template = pageTemplate
            let picTemplate = Template.cached(relativePath: "templates/picture.tpl.html")
            picTemplate.assign("filename", filename)
            
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
            
            template["content"] = picTemplate
            let mainTemplate = wrapTemplate(template)
            mainTemplate.addJS(url: "/editor.js?filename=" + filename)
            mainTemplate.addJS(url: "/script.js")
            return .ok(.html(mainTemplate))
        }
        
        server.notFoundHandler = { request, responseHeaders in
            request.disableKeepAlive = true
            if let filePath = BootstrapTemplate.absolutePath(for: request.path) {
                try HttpFileResponse.with(absolutePath: filePath)
            }
            let filePath = Resource().absolutePath(for: request.path)
            try HttpFileResponse.with(absolutePath: filePath)
            let picturePath = self.picturesPath + "/\(request.path)"
            try HttpFileResponse.with(absolutePath: picturePath)
            print("File `\(filePath)` doesn't exist")
            return .notFound()
        }
    }
}
