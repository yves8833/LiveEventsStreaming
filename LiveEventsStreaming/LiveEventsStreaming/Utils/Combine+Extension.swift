//
//  Combine+Extension.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/20.
//


import Combine
import CombineExt

typealias Driver<Output> = AnyPublisher<Output, Never>

extension Publisher {
    func asDriver(
        onErrorJustReturn fallback: Output
    ) -> Driver<Output> {
        self
            .receive(on: RunLoop.main)
            .replaceError(with: fallback)
            .share(replay: 1)
            .eraseToAnyPublisher()
    }
}
