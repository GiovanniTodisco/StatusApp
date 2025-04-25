//
//  SurveysView.swift
//  StatusApp
//
//  Created by Area mobile on 19/04/25.
//

import UIKit

/// Modelo dei dati per un giorno
struct SurveyDayStatus {
  let date: Date
  let completed: Bool
  let mood: Int?
  let energy: Int?
}

/// View “passiva” che si occupa di mostrare la collection orizzontale
class SurveysView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    let collectionView: UICollectionView
    private(set) var statuses: [SurveyDayStatus] = []
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("survey_intro", comment: "")
        label.numberOfLines = 0
        label.font = AppFont.description
        label.textColor = AppColor.primaryText
        return label
    }()
    
    let seeAllButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = NSLocalizedString("see_last_90", comment: "")
        config.image = UIImage(systemName: "magnifyingglass")
        config.imagePadding = 8
        config.imagePlacement = .leading

        config.baseForegroundColor = AppColor.primaryIcon
        config.baseBackgroundColor = .clear
        config.cornerStyle = .medium 

        let btn = UIButton(configuration: config)
        btn.titleLabel?.font = AppFont.button
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var onSeeAllTapped: (() -> Void)?

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - Constants.APP_MARGIN, height: 120)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
 
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(SurveyStatusCell.self, forCellWithReuseIdentifier: "SurveyStatusCell")
        collectionView.showsVerticalScrollIndicator = false
 
        addSubview(descriptionLabel)
        addSubview(collectionView)
        
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        seeAllButton.setTitle(NSLocalizedString("see_last_90", comment: ""), for: .normal)
        seeAllButton.addTarget(self, action: #selector(handleSeeAllTapped), for: .touchUpInside)
        addSubview(seeAllButton)

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            collectionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            seeAllButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8),
            seeAllButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            seeAllButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func handleSeeAllTapped() {
        onSeeAllTapped?()
    }

    func update(with statuses: [SurveyDayStatus]) {
        self.statuses = statuses
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statuses.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SurveyStatusCell", for: indexPath) as! SurveyStatusCell
        cell.configure(with: statuses[indexPath.item])
        return cell
    }
}
