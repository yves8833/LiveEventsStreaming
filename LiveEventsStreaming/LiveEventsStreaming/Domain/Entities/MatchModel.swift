//
//  MatchModel.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/18.
//


struct MatchModel: Codable {
    let matchID: Int
    let teamA: String
    let teamB: String
    let startTime: String
}