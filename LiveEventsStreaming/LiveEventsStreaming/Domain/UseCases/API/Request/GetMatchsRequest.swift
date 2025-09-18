//
//  GetMatchsRequest.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/18.
//

import Foundation

struct GetMatchsRequest: Endpoint {
    typealias Response = [MatchModel]
    
    var domain: String {
        "https://api.example.com"
    }
    
    var path: String { "/matches" }
    
    var method: String { "GET" }
    
    func decode(_ data: Data) throws -> [MatchModel] {
        try JSONDecoder().decode([MatchModel].self, from: data)
    }
}
