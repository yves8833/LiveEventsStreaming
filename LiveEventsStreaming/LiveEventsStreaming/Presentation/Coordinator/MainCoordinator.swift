//
//  MainCoordinator.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/20.
//

import UIKit
import Foundation
import Combine

protocol MainCoordinatorProtocol: BaseCoordinatorProtocol {
    func showLiveEvents() -> AnyPublisher<Void, Never>
}

extension MainCoordinatorProtocol {
    func showLiveEvents() -> AnyPublisher<Void, Never> {
        let vm = LiveEventsViewModel(dependency: .init(apiUseCase: MockAPIUseCase(), liveEventsUseCase: LiveEventsUseCase(), socketUseCase: MockSocketUseCase()))
        let vc = LiveEventsViewController(viewModel: vm)
        return push(vc, animated: true)
    }
}

class MainCoordinator: MainCoordinatorProtocol {
    weak var viewController: UIViewController?
}
