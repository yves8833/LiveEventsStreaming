//
//  DatabaseService.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/20.
//

import Foundation
import Combine

protocol StorableConvertible {
    associatedtype StorableType: CodableConvertible
    func asStorable() throws -> StorableType
}

protocol CodableConvertible {
    associatedtype CodableType: Decodable
    func asCodable() throws -> CodableType
}

protocol DatabaseService {
    var workerQueue: DispatchQueue { get }
    
    func insertUpdate<T: StorableConvertible>(models: [T]) -> AnyPublisher<Void, any Error>
    func query<T: StorableConvertible>(_ modelType: T.Type) -> AnyPublisher<[T], any Error> where T.StorableType.CodableType == T
}
