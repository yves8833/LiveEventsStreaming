//
//  SocketService.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/20.
//

import Foundation
import Combine

enum SocketStatus: Equatable {
    case disconnected
    case connecting
    case connected
    case error(Error)
    
    static func == (lhs: SocketStatus, rhs: SocketStatus) -> Bool {
        switch (lhs, rhs) {
        case (.connected, .connected), (.disconnected, .disconnected), (.connecting, .connecting):
            return true
        case (.error(let e1), .error(let e2)):
            return (e1 as NSError).domain == (e2 as NSError).domain && (e1 as NSError).code == (e2 as NSError).code
        default:
            return false
        }
    }
    
}

protocol SocketService {
    func connect()
    func disconnect()
    var status: SocketStatus { get }
    func statusPublisher() -> AnyPublisher<SocketStatus, Never>
    func send(_ message: SendSocketMessage) -> AnyPublisher<Void, Error>
    func receive() -> AnyPublisher<Data, Never>
}

class MockSocketService: SocketService {
    private let statusSubject = CurrentValueSubject<SocketStatus, Never>.init(.disconnected)
    private let receiveSubject = PassthroughSubject<Data, Never>()
    private var sendMessage: [SocketMethod: AnyCancellable] = [:]
    private let workQueue = DispatchQueue(label: "MockSocketServiceQueue", qos: .background)
    
    func connect() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.statusSubject.send(.connected)
        }
    }
    
    func disconnect() {
        sendMessage.values.forEach { $0.cancel() }
        sendMessage.removeAll()
        
        statusSubject.send(.disconnected)
    }
    
    var status: SocketStatus {
        return statusSubject.value
    }
    
    func statusPublisher() -> AnyPublisher<SocketStatus, Never> {
        return statusSubject.eraseToAnyPublisher()
    }
    
    func send(_ message: SendSocketMessage) -> AnyPublisher<Void, Error> {
        guard statusSubject.value == .connected else {
            return Fail(error: NSError(domain: "Socket not connected", code: -1, userInfo: nil))
                .eraseToAnyPublisher()
        }
        
        if sendMessage[message.method] == nil {
            sendMessage[message.method] = simulateIncomingData(method: message.method)
        }
        
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func receive() -> AnyPublisher<Data, Never> {
        return receiveSubject.eraseToAnyPublisher()
    }
    
    private func simulateIncomingData(method: SocketMethod) -> AnyCancellable? {
        switch method {
        case .oddUpdate:
            return Timer.publish(every: 0.1, on: .current, in: .common)
                .autoconnect()
                .filter({ _ in Bool.random() })
                .receive(on: workQueue)
                .sink { [weak self] _ in
                    self?.receiveSubject.send(.init())
                }
                
        default:
            return nil
        }
    }
}
    
