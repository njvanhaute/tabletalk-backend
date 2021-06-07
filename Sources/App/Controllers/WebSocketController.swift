//
//  WSClient.swift
//  
//
//  Created by Nicholas Vanhaute on 6/7/21.
//

import Vapor

open class WSClient {
    open var id: UUID
    open var socket: WebSocket

    public init(id: UUID, socket: WebSocket) {
        self.id = id
        self.socket = socket
    }
}

open class WSClientStore {
    var eventLoop: EventLoop
    var store: [UUID: WSClient]
    
    // List of active WSClients
    var active: [WSClient] {
        self.store.values.filter { !$0.socket.isClosed }
    }
    
    init(eventLoop: EventLoop, clients: [UUID: WSClient]) {
        self.eventLoop = eventLoop
        self.store = clients
    }
    
    func add(_ client: WSClient) {
        self.store[client.id] = client
    }
    
    func remove(_ client: WSClient) {
        self.store[client.id] = nil
    }
    
    func find(_ uuid: UUID) -> WSClient? {
        self.store[uuid]
    }
    
    deinit {
        let futures = self.store.values.map { $0.socket.close() }
        try! self.eventLoop.flatten(futures).wait()
    }
}
