//
//  RealmDatabaseService.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/21.
//

import Foundation
import Combine
import RealmSwift

protocol RealmDatabaseService {
    var workerQueue: DispatchQueue { get }
    
    func insertUpdate<T: StorableConvertible>(models: [T]) -> AnyPublisher<Void, any Error> where T.StorableType: Object
    func query<T: StorableConvertible>(_ modelType: T.Type) -> AnyPublisher<[T], any Error> where T.StorableType: Object, T.StorableType.CodableType == T
}

class RealmDatabaseServiceImp: RealmDatabaseService {
    let workerQueue: DispatchQueue = DispatchQueue(label: "RealmDatabaseService", qos: .background)
    
    func realm(configuration: Realm.Configuration) throws -> Realm {
        return try Realm(configuration: configuration)
    }
    
    func insertUpdate<T: StorableConvertible>(models: [T]) -> AnyPublisher<Void, any Error> where T.StorableType: Object {
        Deferred {
            Future { promise in
                self.workerQueue.async {
                    autoreleasepool {
                        do {
                            let realm = try self.realm(configuration: .defaultConfiguration)
                            let objects: [Object] = try models.map { model in
                                try model.asStorable()
                            }
                            try realm.write {
                                realm.add(objects, update: .all)
                            }
                            promise(.success(()))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func query<T: StorableConvertible>(_ modelType: T.Type) -> AnyPublisher<[T], any Error> where T.StorableType: Object, T.StorableType.CodableType == T {
        Deferred {
            Future { promise in
                self.workerQueue.async {
                    autoreleasepool {
                        do {
                            let realm = try self.realm(configuration: .defaultConfiguration)
                            let objects = realm.objects(modelType.StorableType.self)
                            let models: [T] = try objects.map { object in
                                try object.asCodable()
                            }
                            promise(.success(models))
                        } catch {
                            promise(.failure(error))
                        }
                        
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
