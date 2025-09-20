//
//  FPSMonitor.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/20.
//

import QuartzCore
import Combine

final class FPSMonitor {
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount: Int = 0

    private let fpsSubject = PassthroughSubject<Int, Never>()
    var fpsPublisher: AnyPublisher<Int, Never> {
        fpsSubject.eraseToAnyPublisher()
    }
    
    func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(tick(_:)))
        displayLink?.add(to: .main, forMode: .common)
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func tick(_ link: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }
        frameCount += 1
        let delta = link.timestamp - lastTimestamp
        if delta >= 1 {
            let fps = Double(frameCount) / delta
            let roundedFps = Int(round(fps))
            fpsSubject.send(roundedFps)
            
            frameCount = 0
            lastTimestamp = link.timestamp
        }
    }
}
