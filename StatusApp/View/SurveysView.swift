//
//  SurveyDayStatus.swift
//  StatusApp
//
//  Created by Area mobile on 19/04/25.
//

import UIKit

/// Modelo dei dati per un giorno
struct SurveyDayStatus {
  let date: Date
  let completed: Bool
}

/// View “passiva” che si occupa di mostrare la collection orizzontale
class SurveysView: UIView {
    let collectionView: UICollectionView
    private(set) var statuses: [SurveyDayStatus] = []

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 80, height: 80)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(SurveyStatusCell.self, forCellWithReuseIdentifier: "SurveyStatusCell")

        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            collectionView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(with statuses: [SurveyDayStatus]) {
        self.statuses = statuses
        collectionView.reloadData()
    }
}

// Cel­là remain unchanged
class SurveyStatusCell: UICollectionViewCell {
    static let reuseIdentifier = "SurveyStatusCell"
    
    private let circleView = UIView()
    private let dateLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Circle indicator
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.layer.cornerRadius = 20
        contentView.addSubview(circleView)
        
        // Date label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = AppFont.description
        dateLabel.textColor = AppColor.primaryText
        dateLabel.textAlignment = .center
        contentView.addSubview(dateLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            circleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 40),
            circleView.heightAnchor.constraint(equalToConstant: 40),
            
            dateLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4)
        ])
    }
    
    /// Configure cell with a SurveyDayStatus
    func configure(with status: SurveyDayStatus) {
        // Set circle color based on completion
        circleView.backgroundColor = status.completed ? AppColor.successColor : AppColor.errorColor
        
        // Format date as localized short weekday
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale.current
        dateLabel.text = formatter.string(from: status.date)
    }
    
}
