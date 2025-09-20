//
//  Coordinator.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/20.
//

import Foundation
import UIKit
import Combine

protocol BaseCoordinatorProtocol {
    var viewController: UIViewController? { get }
    
    func push(_ viewController: UIViewController, animated: Bool) -> AnyPublisher<Void, Never>
}

extension BaseCoordinatorProtocol {
    func push(_ viewController: UIViewController, animated: Bool = true) -> AnyPublisher<Void, Never> {
        guard let navigationController = self.viewController?.navigationController else {
            return Just(()).eraseToAnyPublisher()
        }
        
        navigationController.pushViewController(viewController, animated: animated)
        
        return Just(()).eraseToAnyPublisher()
    }
}

class BaseCoordinator: BaseCoordinatorProtocol {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
}
