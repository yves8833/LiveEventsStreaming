//
//  DatabaseUseCaseProtocol.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/21.
//

import Foundation
import Combine

protocol DatabaseUseCaseProtocol {
    var service: RealmDatabaseService { get }
    
    func insertUpdate(models: [MatchModel]) -> AnyPublisher<[MatchModel], Error>
    func queryMatchs() -> AnyPublisher<[MatchModel], Error>
    
    func insertUpdate(models: [OddModel]) -> AnyPublisher<[OddModel], Error>
    func queryOdds() -> AnyPublisher<[OddModel], Error>
}

extension DatabaseUseCaseProtocol {
    func insertUpdate(models: [MatchModel]) -> AnyPublisher<[MatchModel], Error> {
        service.insertUpdate(models: models)
            .map { _ in models }
            .eraseToAnyPublisher()
    }
    
    func queryMatchs() -> AnyPublisher<[MatchModel], Error> {
        service.query(MatchModel.self)
    }
    
    func insertUpdate(models: [OddModel]) -> AnyPublisher<[OddModel], Error> {
        service.insertUpdate(models: models)
            .map { _ in models }
            .eraseToAnyPublisher()
    }
    
    func queryOdds() -> AnyPublisher<[OddModel], Error> {
        service.query(OddModel.self)
    }
}

class DatabaseUseCase: DatabaseUseCaseProtocol {
    var service: RealmDatabaseService
    
    init(service: RealmDatabaseService = RealmDatabaseServiceImp()) {
        self.service = service
    }
}
