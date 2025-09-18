//
//  GetOddsRequest.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/19.
//

import Foundation

struct GetOddsRequest: Endpoint {
    typealias Response = [OddModel]
    
    var domain: String {
        "https://api.example.com"
    }
    
    var path: String { "/odds" }
    
    var method: String { "GET" }
    
    func decode(_ data: Data) throws -> [OddModel] {
        try JSONDecoder().decode([OddModel].self, from: data)
    }
}
