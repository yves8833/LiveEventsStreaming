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
        let fetchMatchs = input.loadTrigger
            .setFailureType(to: Error.self)
            .flatMap { _ in
                self.dependency.apiUseCase.fetchMatchs()
                    .zip(self.dependency.apiUseCase.fetchOdds())
            }
            .map { model in
                print(model)
            }
        
        let data = input.loadTrigger
            .map { models -> [Section<Model>] in
                let items: [Model] = (0..<100).map { i in
                    let time = Date().addingTimeInterval(Double(-i * 3600))
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let timeString = dateformatter.string(from: time)
                    let oddA = Double.random(in: 1.0...5.0)
                    let oddB = Double.random(in: 1.0...5.0)
                    return Model(teamA: "teamA_\(i)", teamB: "teamB_\(i)", startTime: timeString, oddA: oddA, oddB: oddB)
                }
                let section = Section(header: "", items: items)
                return [section]
            }
            .delay(for: .seconds(0.3), scheduler: RunLoop.current)
            .eraseToAnyPublisher()
        
        let configure = fetchMatchs
            .ignoreFailure()
            
        return Output(data: data, configure: configure)
    }
}

extension ViewModel {
    struct Input {
        let loadTrigger: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let data: AnyPublisher<[Section<Model>], Never>
        let configure: AnyPublisher<Void, Never>
    }
    
    struct Dependency {
        var apiUseCase: APIUseCaseProtocol
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
