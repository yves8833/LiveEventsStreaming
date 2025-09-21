//
//  RMOddModel.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/21.
//


import RealmSwift

class RMOddModel: Object {
    @Persisted(primaryKey: true) var matchID: Int
    @Persisted var teamAOdds: Double
    @Persisted var teamBOdds: Double
    
    convenience init(model: OddModel) {
        self.init()
        self.matchID = model.matchID
        self.teamAOdds = model.teamAOdds
        self.teamBOdds = model.teamBOdds
    }
}

extension RMOddModel: CodableConvertible {
    func asCodable() throws -> OddModel {
        return OddModel(matchID: matchID, teamAOdds: teamAOdds, teamBOdds: teamBOdds)
    }
}

extension OddModel: StorableConvertible {
    func asStorable() throws -> RMOddModel {
        return RMOddModel(model: self)
    }
}
