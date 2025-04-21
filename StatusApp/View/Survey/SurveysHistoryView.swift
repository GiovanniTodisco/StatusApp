//
//  SurveysHistoryView.swift
//  StatusApp
//
//  Created by Area mobile on 21/04/25.
//


import UIKit

/// View che mostra la lista storica dei sondaggi completati
class SurveysHistoryView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    let collectionView: UICollectionView
    private(set) var statuses: [SurveyDayStatus] = []

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

        addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
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
