//
//  ViewController.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/17.
//

import UIKit
import Combine
import CombineExt
import CombineDataSources

class ViewController: UIViewController {
    private var cancelBag = Set<AnyCancellable>()
    
    private let viewModel = ViewModel(dependency: .init(apiUseCase: MockAPIUseCase(), liveEventsUseCase: LiveEventsUseCaseImpl(), socketUseCase: MockSocketUseCase()))
    
    private let monitor: FPSMonitor = .init()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.text = "Live Events Streaming"
        
        return label
    }()
    
    private lazy var fpsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .right
        
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(LiveEventsStreamingTableViewCell.self, forCellReuseIdentifier: LiveEventsStreamingTableViewCell.reuseIdentifier)
        
        return tableView
    }()
    
    private lazy var dataSource: TableViewItemsController<[Section<ViewModel.Model>]> = {
        let dataSource = TableViewItemsController<[Section<ViewModel.Model>]>.init(cellIdentifier: LiveEventsStreamingTableViewCell.reuseIdentifier, cellType: LiveEventsStreamingTableViewCell.self, cellConfig: { cell, _, model in
            cell.configure(with: model)
        })
        dataSource.rowAnimations = (.top, .top, .top)
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutViews()
        bindViewModel()
    }
}

extension ViewController {
    private func layoutViews() {
        view.addSubview(nameLabel)
        view.addSubview(fpsLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameLabel.heightAnchor.constraint(equalToConstant: 44),
            
            fpsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            fpsLabel.heightAnchor.constraint(equalToConstant: 20),
            fpsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: fpsLabel.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func bindViewModel() {
        let loadTrigger = CurrentValueSubject<Void, Never>(())
        defer {
            loadTrigger.send(())
        }
        
        monitor.start()
        
        monitor.fpsPublisher
            .sink { [weak self] fps in
                self?.fpsLabel.text = "FPS: \(fps)"
            }
            .store(in: &cancelBag)
        
        let output = viewModel.transform(input: .init(
            loadTrigger: loadTrigger.eraseToAnyPublisher(),
            viewWillAppear: viewWillAppearPublisher
                .mapToVoid()
                .eraseToAnyPublisher(),
            viewWillDisappear: viewWillDisappearPublisher
                .mapToVoid()
                .eraseToAnyPublisher(),
        ))
        
        output.models
            .throttle(for: .milliseconds(300), scheduler: RunLoop.main, latest: true)
            .bind(subscriber: tableView.sectionsSubscriber(dataSource))
            .store(in: &cancelBag)
        
        output.configure
            .sink(receiveValue: {})
            .store(in: &cancelBag)
    }
}
