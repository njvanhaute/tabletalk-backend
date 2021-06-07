//
//  File.swift
//  
//
//  Created by Nicholas Vanhaute on 6/7/21.
//

import Foundation
import Vapor

struct WSMessage<T: Codable>: Codable {
    let clientId: UUID
    let data: T
}

struct WSConnect: Codable {
    let connect: Bool
}

extension ByteBuffer {
    func decodeWSMessage<T: Codable>(_ type: T.Type) -> WSMessage<T>? {
        try? JSONDecoder().decode(WSMessage<T>.self, from: self)
    }
}
