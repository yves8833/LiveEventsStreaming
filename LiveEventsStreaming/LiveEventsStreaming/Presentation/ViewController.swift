//
//  ViewController.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/20.
//

import UIKit
import Combine
import CombineCocoa

class ViewController: UIViewController {
    private var cancelBag = Set<AnyCancellable>()
    private lazy var viewModel: ViewModel = {
        let coordinator = MainCoordinator()
        let viewModel = ViewModel(dependency: .init(coordinator: coordinator))
        coordinator.viewController = self
        return viewModel
    }()
    
    private lazy var testButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Match Events", for: .normal)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        bindViewModel()
    }
}

extension ViewController {
    func setupViews() {
        view.addSubview(testButton)
        
        testButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            testButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func bindViewModel() {
        let output = viewModel.transform(input: .init(didTapButton: testButton.tapPublisher))
        
        output.configure
            .sink(receiveValue: {})
            .store(in: &cancelBag)
    }
}
