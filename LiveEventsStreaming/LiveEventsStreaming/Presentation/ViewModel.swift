//
//  ViewModel.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/20.
//

import Foundation
import Combine

class ViewModel {
    let dependency: Dependency
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func transform(input: Input) -> Output {
        let configure = input.didTapButton
            .flatMap { _ in
                return self.dependency.coordinator.showLiveEvents()
            }
            .asDriver(onErrorJustReturn: ())
        
        return Output(configure: configure)
    }
}

extension ViewModel {
    struct Input {
        let didTapButton: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let configure: Driver<Void>
    }
    
    struct Dependency {
        var coordinator: MainCoordinatorProtocol
    }
}
