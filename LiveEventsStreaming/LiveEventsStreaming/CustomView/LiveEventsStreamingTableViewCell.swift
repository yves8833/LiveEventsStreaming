//
//  LiveEventsStreamingTableViewCell.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/18.
//

import UIKit

class LiveEventsStreamingTableViewCell: UITableViewCell {
    static let reuseIdentifier = String(describing: LiveEventsStreamingTableViewCell.self)

    private lazy var teamANameLabel: UILabel = makeTeamNameLabel(alignment: .left)
    private lazy var teamAOddLabel: UILabel = makeTeamOddLabel(alignment: .right)
    private lazy var teamBOddLabel: UILabel = makeTeamOddLabel(alignment: .left)
    private lazy var teamBNameLabel: UILabel = makeTeamNameLabel(alignment: .right)
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .right
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    private func makeTeamNameLabel(alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = alignment
        
        return label
    }
    
    private func makeTeamOddLabel(alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = alignment
        
        return label
    }
    
    private func makeTeamStackView(arrangedSubviews: [UIView]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: arrangedSubviews)
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let teamAStackView = makeTeamStackView(arrangedSubviews: [teamANameLabel, teamAOddLabel])
        let teamBStackView = makeTeamStackView(arrangedSubviews: [teamBOddLabel, teamBNameLabel])
        
        let teamStackView = UIStackView(arrangedSubviews: [teamAStackView, teamBStackView])
        teamStackView.axis = .horizontal
        teamStackView.distribution = .fillEqually   // ✅ 取代「等寬」constraint
        teamStackView.spacing = 16
        teamStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(teamStackView)
        contentView.addSubview(timeLabel)
        NSLayoutConstraint.activate([
            teamStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            teamStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            teamStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            timeLabel.topAnchor.constraint(equalTo: teamStackView.bottomAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            timeLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            
            teamANameLabel.heightAnchor.constraint(equalToConstant: 40),
            teamBNameLabel.heightAnchor.constraint(equalTo: teamANameLabel.heightAnchor),
            
            teamAOddLabel.heightAnchor.constraint(equalTo: teamANameLabel.heightAnchor),
            teamBOddLabel.heightAnchor.constraint(equalTo: teamANameLabel.heightAnchor),
            teamAOddLabel.widthAnchor.constraint(equalToConstant: 50),
            teamBOddLabel.widthAnchor.constraint(equalTo: teamAOddLabel.widthAnchor),
        ])
    }
    
    func configure(with model: LiveEventsViewModel.Model) {
        teamANameLabel.text = model.teamA
        teamBNameLabel.text = model.teamB
        teamAOddLabel.text = String(format: "%.2f", model.oddA)
        teamBOddLabel.text = String(format: "%.2f", model.oddB)
        timeLabel.text = model.startTime
    }
}
