//
//  LiveEventsUseCase.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/19.
//

import Foundation
import CombineDataSources

protocol LiveEventsUseCase {
    func getDisplayModels(matchs: [MatchModel], odds: [OddModel]) -> [Section<ViewModel.Model>]
}

extension LiveEventsUseCase {
    func getDisplayModels(matchs: [MatchModel], odds: [OddModel]) -> [Section<ViewModel.Model>] {
        var models = matchs.compactMap { match -> ViewModel.Model? in
            guard let odd = odds.first(where: { $0.matchID == match.matchID }) else {
                return nil
            }
            return .init(teamA: match.teamA, teamB: match.teamB, startTime: match.startTime, oddA: odd.teamAOdds, oddB: odd.teamBOdds)
        }
        models.sort { $0.startTime > $1.startTime }
        return [.init(items: models)]
    }
}

class LiveEventsUseCaseImpl: LiveEventsUseCase {}
