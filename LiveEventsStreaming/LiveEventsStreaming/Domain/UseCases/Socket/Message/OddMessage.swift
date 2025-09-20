//
//  OddMessage.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/20.
//

import Foundation

struct SendOddMessage: SendSocketMessage {
    let method: SocketMethod = .oddUpdate
}

struct OddMessage: SocketMessage {
    let id: Int
    let method: SocketMethod
    
    let matchID: Int
    let oddA: Double
    let oddB: Double
}
