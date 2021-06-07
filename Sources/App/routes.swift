import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    let wsController = WebSocketController(eventLoop: app.eventLoopGroup.next())
    let roomController = TTRoomController()
    
    app.webSocket("conn") { req, ws in
        wsController.connect(ws)
    }
    
    app.webSocket("room") { req, ws in
        roomController.connect(ws)
    }
}
