//
//  SocketMessage.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/20.
//

protocol SendSocketMessage {
    var method: SocketMethod { get }
}

protocol SocketMessage: Codable {
    var id: Int { get }
    var method: SocketMethod { get }
}

enum SocketMethod: String, Codable {
    case oddUpdate
    case unknown
}
