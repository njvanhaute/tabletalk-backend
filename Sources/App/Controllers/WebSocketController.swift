//
//  WebSocketController.swift
//  
//
//  Created by Nicholas Vanhaute on 6/7/21.
//

import Vapor

enum WSSendOption {
    case id(UUID), ids([UUID]), socket(WebSocket)
}

open class WSClientStore {
    var lock: Lock
    var eventLoop: EventLoop
    var store: [UUID: WebSocket]
    
    init(eventLoop: EventLoop, clients: [UUID: WebSocket] = [:]) {
        self.lock = Lock()
        self.eventLoop = eventLoop
        self.store = clients
    }
    
    func add(id: UUID, socket: WebSocket) {
        // Ensure that client is removed from store upon WS close.
        socket.onClose.whenComplete { _ in
            self.remove(id)
        }
        
        self.lock.withLockVoid {
            self.store[id] = socket
        }
        print("Successfully added client. # clients =  \(store.count)")
    }
    
    func remove(_ id: UUID) {
        self.lock.withLockVoid {
            self.store[id] = nil
        }
        print("Successfully removed client. # clients = \(store.count)")
    }
    
    func find(_ id: UUID) -> WebSocket? {
        var result: WebSocket? = nil
        self.lock.withLockVoid {
            result = self.store[id]
        }
        return result
    }
    
    func findMultiple(_ ids: [UUID]) -> [WebSocket] {
        var result: [WebSocket] = []
        self.lock.withLockVoid {
            result = self.store.filter { key, _ in ids.contains(key) }.map { $1 }
        }
        return result
    }
    
    deinit {
        let futures = self.store.values.map { $0.close() }
        try! self.eventLoop.flatten(futures).wait()
    }
}

class WebSocketController {
    var clients: WSClientStore
    
    init(eventLoop: EventLoop) {
        self.clients = WSClientStore(eventLoop: eventLoop)
    }
    
    func connect(_ ws: WebSocket) {
        // On initial connection:
        //    1. Create new WSClient object, assigning user unique ID
        //    2. Add client to store
        //    3. Send response message indicating client's uid.
        
        let uuid = UUID()
        clients.add(id: uuid, socket: ws)
        ws.onBinary { [weak self] ws, buffer in
            guard let self = self,
                  let data = buffer.getData(at: buffer.readerIndex,
                                            length: buffer.readableBytes) else { return }
            self.onData(ws, data)
        }
        
        ws.onText { [weak self] ws, text in
            guard let self = self,
                  let data = text.data(using: .utf8) else { return }
            self.onData(ws, data)
        }
        
        self.send(message: WSHandshake(id: uuid), to: .socket(ws))
    }
    
    func onData(_ ws: WebSocket, _ data: Data) {
        let decoder = JSONDecoder()
        do {
            let meta = try decoder.decode(WSMessageMetadata.self, from: data)
            switch meta.type {
            default:
                break
            }
        } catch {
            print(error)
        }
    }
    
    func send<T: Codable>(message: T, to sendOption: WSSendOption) {
        print("Sending \(T.self) to \(sendOption)")
        do {
            var sockets: [WebSocket] = []
            switch sendOption {
            case .id(let id):
                sockets = [clients.find(id)!]
            case .ids(let ids):
                sockets = clients.findMultiple(ids)
            case .socket(let socket):
                sockets = [socket]
            }
            
            let encoder = JSONEncoder()
            let data = try encoder.encode(message)
            
            sockets.forEach {
                $0.send(raw: data, opcode: .binary)
            }
        } catch {
            print(error)
        }
    }
}
