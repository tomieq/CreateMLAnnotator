import Foundation
import Swifter


let server = HttpServer()
let frontend = Frontend(server)
try? server.start(8080)
print("Started CoreMLAnnotator on port: \(try! server.port())")
RunLoop.main.run()
