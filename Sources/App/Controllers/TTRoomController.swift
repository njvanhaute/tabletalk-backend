//
//  File.swift
//  
//
//  Created by Nicholas Vanhaute on 6/7/21.
//

import Foundation
import Vapor

enum TTRoomError: Error {
    case invalidId
    case roomFull
}

class TTRoom {
    var roomId: UUID
    var players: [TTPlayer]
    
    init(roomId: UUID, players: [TTPlayer] = []) {
        self.roomId = roomId
        self.players = players
    }
}

class TTRoomController {
    var store: [UUID: TTRoom]
    
    init(store: [UUID: TTRoom] = [:]) {
        self.store = store
    }
    
    func createRoom() -> UUID {
        let id = UUID()
        let newRoom = TTRoom(roomId: id)
        self.store[id] = newRoom
        return id
    }
    
    func removeRoom(id: UUID) {
        self.store[id] = nil
    }
    
    func addPlayer(_ player: TTPlayer, toRoom: UUID) throws {
        guard let room = self.store[toRoom] else {
            throw TTRoomError.invalidId
        }
        
        if (room.players.count == 4) {
            throw TTRoomError.roomFull
        }
        
        room.players.append(player)
    }
    
    func connect(_ ws: WebSocket) {
        // TODO: Parse request.
        //    Either create new room or add user to existing room.
        //    Upon create room, should return room ID.
        //    Upon add user, should return success or failure
    }
}
