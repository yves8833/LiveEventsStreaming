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

class LiveEventsViewController: UIViewController {
    private var cancelBag = Set<AnyCancellable>()
    
    private let viewModel: LiveEventsViewModel
    
    private let monitor: FPSMonitor = .init()
    
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
    
    private lazy var dataSource: TableViewItemsController<[Section<LiveEventsViewModel.Model>]> = {
        let dataSource = TableViewItemsController<[Section<LiveEventsViewModel.Model>]>.init(cellIdentifier: LiveEventsStreamingTableViewCell.reuseIdentifier, cellType: LiveEventsStreamingTableViewCell.self, cellConfig: { cell, _, model in
            cell.configure(with: model)
        })
        dataSource.rowAnimations = (.top, .top, .top)
        return dataSource
    }()
    
    init(viewModel: LiveEventsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutViews()
        bindViewModel()
    }
}

extension LiveEventsViewController {
    private func layoutViews() {
        title = "Live Events"
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = .systemBackground
        
        view.addSubview(fpsLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            fpsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            fpsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fpsLabel.heightAnchor.constraint(equalToConstant: 20),
            
            tableView.topAnchor.constraint(equalTo: fpsLabel.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func bindViewModel() {
        let loadTrigger = PassthroughSubject<Void, Never>()
        defer {
            loadTrigger.send(())
        }
        
        viewWillAppearPublisher
            .sink { [weak self] _ in
                self?.monitor.start()
            }
            .store(in: &cancelBag)
        
        viewWillDisappearPublisher
            .sink { [weak self] _ in
                self?.monitor.stop()
            }
            .store(in: &cancelBag)
        
        monitor.fpsPublisher
            .sink { [weak self] fps in
                self?.fpsLabel.text = "FPS: \(fps)"
            }
            .store(in: &cancelBag)
        
        let isViewAppear = viewWillAppearPublisher.map { _ in true }
            .merge(with: viewWillDisappearPublisher.map { _ in false })
            .eraseToAnyPublisher()
        
        let viewAppearEnterForeground = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .withLatestFrom(isViewAppear)
            .filter({ $0 })
            .mapToVoid()
            .eraseToAnyPublisher()
        
        let viewAppearEnterBackground = NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .withLatestFrom(isViewAppear)
            .filter({ $0 })
            .mapToVoid()
            .eraseToAnyPublisher()
        
        let output = viewModel.transform(input: .init(
            loadTrigger: loadTrigger.eraseToAnyPublisher(),
            viewWillAppear: viewWillAppearPublisher,
            viewWillDisappear: viewWillDisappearPublisher,
            viewAppearEnterForeground: viewAppearEnterForeground,
            viewAppearEnterBackground: viewAppearEnterBackground
        ))
        
        output.models
            .bind(subscriber: tableView.sectionsSubscriber(dataSource))
            .store(in: &cancelBag)
        
        output.configure
            .sink(receiveValue: {})
            .store(in: &cancelBag)
    }
}
