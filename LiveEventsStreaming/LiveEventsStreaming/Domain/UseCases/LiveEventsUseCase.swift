//
//  LiveEventsUseCase.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/19.
//

import Foundation
import CombineDataSources
import Combine

protocol LiveEventsUseCase {
    func getDisplayModels(matchs: [MatchModel], odds: [OddModel]) -> [Section<ViewModel.Model>]
    func updateDisplayModels(models: [Section<ViewModel.Model>], with oddMessages: OddMessage) -> AnyPublisher<[Section<ViewModel.Model>], Never>
}

extension LiveEventsUseCase {
    func updateDisplayModels(models: [Section<ViewModel.Model>], with oddMessage: OddMessage) -> AnyPublisher<[Section<ViewModel.Model>], Never> {
        guard var items = models.first?.items,
              let index = items.firstIndex(where: { model in
                  model.matchId == oddMessage.matchID
              }) else {
            return Empty()
                .eraseToAnyPublisher()
        }
        var item = items[index]
        item.oddA = oddMessage.oddA
        item.oddB = oddMessage.oddB
        items[index] = item
        let models: [Section<ViewModel.Model>] = [.init(items: items)]
        return Just(models)
            .eraseToAnyPublisher()
    }
}

class LiveEventsUseCaseImpl: LiveEventsUseCase {
    private lazy var parserDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    private lazy var displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    func getDisplayModels(matchs: [MatchModel], odds: [OddModel]) -> [Section<ViewModel.Model>] {
        var models = matchs.compactMap { match -> ViewModel.Model? in
            guard let odd = odds.first(where: { $0.matchID == match.matchID }) else {
                return nil
            }
            let startDate = parserDateFormatter.date(from: match.startTime) ?? Date()
            let startTimeString = displayDateFormatter.string(from: startDate)
            return .init(matchId: match.matchID, teamA: match.teamA, teamB: match.teamB, startTime: startTimeString, oddA: odd.teamAOdds, oddB: odd.teamBOdds)
        }
        models.sort { $0.startTime < $1.startTime }
        return [.init(items: models)]
    }
}
