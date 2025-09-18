//
//  ViewModel.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/18.
//

import Foundation
import Combine
import CombineDataSources
import CombineExt

class ViewModel {
    private let dependency: Dependency
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func transform(input: Input) -> Output {
        let models = input.loadTrigger
            .setFailureType(to: Error.self)
            .flatMap { _ in
                self.dependency.apiUseCase.fetchMatchs()
                    .zip(self.dependency.apiUseCase.fetchOdds())
            }
            .map { matchs, odds in
                self.dependency.liveEventsUseCase.getDisplayModels(matchs: matchs, odds: odds)
            }
            .ignoreFailure()
            .eraseToAnyPublisher()
            
        return Output(models: models, configure: Just(()).eraseToAnyPublisher())
    }
}

extension ViewModel {
    struct Input {
        let loadTrigger: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let models: AnyPublisher<[Section<Model>], Never>
        let configure: AnyPublisher<Void, Never>
    }
    
    struct Dependency {
        var apiUseCase: APIUseCaseProtocol
        var liveEventsUseCase: LiveEventsUseCase
    }
    
    struct Model: Identifiable, Hashable {
        var id: String {
            return teamA + teamB + startTime
        }
        
        let teamA: String
        let teamB: String
        let startTime: String
        let oddA: Double
        let oddB: Double
    }
}
