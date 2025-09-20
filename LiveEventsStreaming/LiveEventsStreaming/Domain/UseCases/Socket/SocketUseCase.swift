//
//  SocketService.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/20.
//

import Foundation
import Combine

protocol SocketUseCaseProtocol {
    var service: SocketService { get }
    
    func isConnected() -> AnyPublisher<Bool, Never>
    func attach()
    func detach()
    func send(_ message: SendSocketMessage) -> AnyPublisher<Void, Error>
    func receiveOdd() -> AnyPublisher<OddMessage, Never>
}

class MockSocketUseCase: SocketUseCaseProtocol {
    var service: SocketService = MockSocketService()
    var attachCount: CurrentValueSubject<Int, Never> = .init(0)
    var cancelBag = Set<AnyCancellable>()
    
    init() {
        attachCount
            .sink { [weak self] count in
                guard let self else { return }
                if count > 0 {
                    guard service.status != .connected || service.status != .connecting else { return }
                    self.service.connect()
                } else {
                    self.service.disconnect()
                }
            }
            .store(in: &cancelBag)
    }
    
    func isConnected() -> AnyPublisher<Bool, Never> {
        service.statusPublisher()
            .map { $0 == .connected }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func attach() {
        attachCount.send(attachCount.value + 1)
    }
    
    func detach() {
        attachCount.send(attachCount.value - 1)
    }
    
    func send(_ message: SendSocketMessage) -> AnyPublisher<Void, Error> {
        service.send(message)
    }
    
    func receiveOdd() -> AnyPublisher<OddMessage, Never> {
        service.receive()
            .compactMap { data -> OddMessage? in
                let matchID = (1001...1100).randomElement() ?? 1001
                let oddA = Double.random(in: 1.0...5.0)
                let oddB = Double.random(in: 1.0...5.0)
                return OddMessage(id: 0, method: .oddUpdate, matchID: matchID, oddA: oddA, oddB: oddB)
            }
            .eraseToAnyPublisher()
    }
}

