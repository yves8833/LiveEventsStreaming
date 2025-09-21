//
//  RMMatchModel.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/21.
//


import RealmSwift

class RMMatchModel: Object {
    @Persisted(primaryKey: true) var matchID: Int
    @Persisted var teamA: String
    @Persisted var teamB: String
    @Persisted var startTime: String
    
    convenience init(model: MatchModel) {
        self.init()
        self.matchID = model.matchID
        self.teamA = model.teamA
        self.teamB = model.teamB
        self.startTime = model.startTime
    }
}

extension RMMatchModel: CodableConvertible {
    func asCodable() throws -> MatchModel {
        return MatchModel(matchID: matchID, teamA: teamA, teamB: teamB, startTime: startTime)
    }
}

extension MatchModel: StorableConvertible {
    func asStorable() throws -> RMMatchModel {
        return RMMatchModel(model: self)
    }
}
