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
    private let workQueue = DispatchQueue(label: "ViewModel", qos: .userInitiated)
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func transform(input: Input) -> Output {
        let updatedModels = PassthroughSubject<[Section<Model>], Never>()
        let defaultModels = input.loadTrigger
            .setFailureType(to: Error.self)
            .flatMap { _ in
                self.dependency.apiUseCase.fetchMatchs()
                    .zip(self.dependency.apiUseCase.fetchOdds())
            }
            .map { matchs, odds in
                self.dependency.liveEventsUseCase.getDisplayModels(matchs: matchs, odds: odds)
            }
            .ignoreFailure()
            .receive(on: workQueue)
            .eraseToAnyPublisher()
        
        let models = defaultModels
            .merge(with: updatedModels)
            .eraseToAnyPublisher()
            .asDriver(onErrorJustReturn: [])
        
        let isViewAppear = input.viewWillAppear.map { _ in true }
            .merge(with: input.viewWillDisappear.map { _ in false })
            .eraseToAnyPublisher()
        
        let enterForeground = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .withLatestFrom(isViewAppear)
            .filter({ $0 })
            .mapToVoid()
        
        let enterBackground = NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .withLatestFrom(isViewAppear)
            .filter({ $0 })
            .mapToVoid()
            
        let shouldAttachSocket = input.viewWillAppear
            .merge(with: enterForeground)
        
        let shouldDeattachSocket = input.viewWillDisappear
            .merge(with: enterBackground)
        
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
            .receive(on: workQueue)
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

extension ViewModel {
    struct Input {
        let loadTrigger: AnyPublisher<Void, Never>
        let viewWillAppear: AnyPublisher<Void, Never>
        let viewWillDisappear: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let models: Driver<[Section<Model>]>
        let configure: Driver<Void>
    }
    
    struct Dependency {
        var apiUseCase: APIUseCaseProtocol
        var liveEventsUseCase: LiveEventsUseCase
        var socketUseCase: SocketUseCaseProtocol
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
