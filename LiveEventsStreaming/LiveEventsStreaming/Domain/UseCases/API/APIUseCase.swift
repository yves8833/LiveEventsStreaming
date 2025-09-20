//
//  APIUseCase.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/18.
//

import Foundation
import Combine

protocol APIUseCaseProtocol {
    var service: any APIServiceProtocol { get }
    
    func fetchMatchs() -> AnyPublisher<GetMatchsRequest.Response, Error>
    func fetchOdds() -> AnyPublisher<GetOddsRequest.Response, Error>
}

extension APIUseCaseProtocol {
    func fetchMatchs() -> AnyPublisher<GetMatchsRequest.Response, Error> {
        service.request(GetMatchsRequest())
    }
    
    func fetchOdds() -> AnyPublisher<GetOddsRequest.Response, Error> {
        service.request(GetOddsRequest())
    }
}

class APIUseCase: APIUseCaseProtocol {
    let service: APIServiceProtocol
    init(service: any APIServiceProtocol) {
        self.service = service
    }
}

class MockAPIUseCase: APIUseCaseProtocol {
    enum MockError: Error {
        case fileNotFound
        case dataCorrupted
    }
    let service: any APIServiceProtocol
    init(service: any APIServiceProtocol = MockAPIService()) {
        self.service = service
    }
    
    func fetchMatchs() -> AnyPublisher<GetMatchsRequest.Response, Error> {
        guard let mockMatchsURL = Bundle.main.url(forResource: "mock_matchs", withExtension: "json") else {
            return Fail<GetMatchsRequest.Response, Error>(error: MockError.fileNotFound)
                .eraseToAnyPublisher()
        }
        
        do {
            let data = try Data(contentsOf: mockMatchsURL)
            let mockData = try GetMatchsRequest().decode(data)
            return Just(mockData)
                .delay(for: .seconds(0.3), scheduler: RunLoop.current)
                .setFailureType(to: Error.self)
                .receive(on: DispatchQueue.global(qos: .background))
                .eraseToAnyPublisher()
        } catch {
            return Fail<GetMatchsRequest.Response, Error>(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchOdds() -> AnyPublisher<GetOddsRequest.Response, Error> {
        guard let mockOddsURL = Bundle.main.url(forResource: "mock_odds", withExtension: "json") else {
            return Fail<GetOddsRequest.Response, Error>(error: MockError.fileNotFound)
                .eraseToAnyPublisher()
        }
        
        do {
            let data = try Data(contentsOf: mockOddsURL)
            let mockData = try GetOddsRequest().decode(data)
            return Just(mockData)
                .delay(for: .seconds(0.3), scheduler: RunLoop.current)
                .setFailureType(to: Error.self)
                .receive(on: DispatchQueue.global(qos: .background))
                .eraseToAnyPublisher()
        } catch {
            return Fail<GetOddsRequest.Response, Error>(error: error)
                .eraseToAnyPublisher()
        }
    }
}
