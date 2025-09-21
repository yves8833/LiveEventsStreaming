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

class LiveEventsViewModel {
    private let dependency: Dependency
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func transform(input: Input) -> Output {
        let updatedModels = PassthroughSubject<[Section<Model>], Never>()
        let localModels = input.loadTrigger
            .setFailureType(to: Error.self)
            .flatMap { _ in
                self.dependency.databaseUseCase.queryMatchs()
                    .zip(self.dependency.databaseUseCase.queryOdds())
                    .eraseToAnyPublisher()
            }
            
        let remoteModels = input.loadTrigger
            .setFailureType(to: Error.self)
            .flatMap { _ in
                let fetchMatch = self.dependency.apiUseCase.fetchMatchs()
                    .flatMap({ models in
                        self.dependency.databaseUseCase.insertUpdate(models: models)
                    })
                
                let fetchOdds = self.dependency.apiUseCase.fetchOdds()
                    .flatMap({ models in
                        self.dependency.databaseUseCase.insertUpdate(models: models)
                    })
                return fetchMatch
                    .zip(fetchOdds)
                    .eraseToAnyPublisher()
            }
        
        let fetchModels = localModels
            .merge(with: remoteModels)
            .map { matchs, odds in
                self.dependency.liveEventsUseCase.getDisplayModels(matchs: matchs, odds: odds)
            }
            .replaceError(with: [])
            .receive(on: self.dependency.workQueue)
            .eraseToAnyPublisher()
        
        let models = fetchModels
            .merge(with: updatedModels)
            .eraseToAnyPublisher()
            .asDriver(onErrorJustReturn: [])
        
        let shouldAttachSocket = input.viewWillAppear
            .merge(with: input.viewAppearEnterForeground)
        
        let shouldDeattachSocket = input.viewWillDisappear
            .merge(with: input.viewAppearEnterBackground)
        
        let attachSocket = shouldAttachSocket
            .handleEvents(receiveOutput: { _ in
                self.dependency.socketUseCase.attach()
            })
        
        let deattachSocket = shouldDeattachSocket
            .handleEvents(receiveOutput: { _ in
                self.dependency.socketUseCase.detach()
            })
        
        let observeOdds = self.dependency.socketUseCase.isConnected()
            .flatMapLatest({ isConnected -> AnyPublisher<Void, Never> in
                guard isConnected else {
                    return Empty<Void, Never>().eraseToAnyPublisher()
                }
                return self.dependency.socketUseCase.send(SendOddMessage())
                    .ignoreFailure(setFailureType: Never.self)
                    .eraseToAnyPublisher()
            })
        
        let receiveOdds = observeOdds
            .flatMap { _ in
                self.dependency.socketUseCase.receiveOdd()
            }
        
        let updateModels = receiveOdds
            .receive(on: self.dependency.workQueue)
            .withLatestFrom(models) { ($0, $1) }
            .flatMap(maxPublishers: .max(1)) { message, models in
                self.dependency.liveEventsUseCase.updateDisplayModels(models: models, with: message)
                    .eraseToAnyPublisher()
            }
            .map {
                updatedModels.send($0)
            }
        
        let configure = attachSocket
            .merge(with: deattachSocket)
            .merge(with: updateModels)
            .eraseToAnyPublisher()
            .asDriver(onErrorJustReturn: ())
        
        return Output(models: models, configure: configure)
    }
}

extension LiveEventsViewModel {
    struct Input {
        let loadTrigger: AnyPublisher<Void, Never>
        let viewWillAppear: AnyPublisher<Void, Never>
        let viewWillDisappear: AnyPublisher<Void, Never>
        let viewAppearEnterForeground: AnyPublisher<Void, Never>
        let viewAppearEnterBackground: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let models: Driver<[Section<Model>]>
        let configure: Driver<Void>
    }
    
    struct Dependency {
        var apiUseCase: APIUseCaseProtocol = MockAPIUseCase()
        var liveEventsUseCase: LiveEventsUseCaseProtocol = LiveEventsUseCase()
        var socketUseCase: SocketUseCaseProtocol = MockSocketUseCase()
        var databaseUseCase: DatabaseUseCaseProtocol = DatabaseUseCase()
        var workQueue = DispatchQueue(label: "LiveEventsViewModel", qos: .userInitiated)
    }
    
    struct Model: Identifiable, Hashable {
        var id: String {
            return "\(matchId)\(teamA)\(teamB)\(oddA)\(oddB)"
        }
        
        let matchId: Int
        let teamA: String
        let teamB: String
        let startTime: String
        var oddA: Double
        var oddB: Double
    }
}
