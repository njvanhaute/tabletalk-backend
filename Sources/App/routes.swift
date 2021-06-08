import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    let wsController = WebSocketController(eventLoop: app.eventLoopGroup.next())
    
    app.webSocket("tt") { req, ws in
        wsController.connect(ws)
    }
}
