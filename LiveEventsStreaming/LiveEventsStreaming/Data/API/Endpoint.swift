//
//  Endpoint.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/18.
//

import Foundation

protocol Endpoint {
    associatedtype Response: Codable
    
    var domain: String { get }
    var path: String { get }
    var method: String { get }
    var body: Data? { get }
    func decode(_ data: Data) throws -> Response
}

extension Endpoint {
    var body: Data? { nil }
}
