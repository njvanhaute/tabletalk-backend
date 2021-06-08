//
//  WSMessageTypes.swift
//  
//
//  Created by Nicholas Vanhaute on 6/7/21.
//

import Foundation

enum WSMessageType: String, Codable {
    // Server to client types
    case handshake
}

struct WSMessageMetadata: Codable {
    let type: WSMessageType
    let id: UUID
}

struct WSHandshake: Codable {
    var type = WSMessageType.handshake
    let id: UUID
}
