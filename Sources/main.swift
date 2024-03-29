import Foundation
import Swifter


let server = HttpServer()
let frontend = Frontend(server)
try? server.start(8080)
print("Started Deobfuscator on port: \(try! server.port())")
RunLoop.main.run()
