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
        label.text = "In questa sezione puoi visualizzare lo stato dei sondaggi giornalieri completati o mancati negli ultimi 7 giorni, insieme al tuo umore ed energia. Completare regolarmente i sondaggi aiuta a monitorare il tuo benessere nel tempo."
        label.numberOfLines = 0
        label.font = AppFont.info
        label.textColor = AppColor.primaryText
        return label
    }()

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - Constants.APP_MARGIN, height: 100)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
 
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(SurveyStatusCell.self, forCellWithReuseIdentifier: "SurveyStatusCell")
 
        addSubview(descriptionLabel)
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            collectionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -2)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

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

class SurveyStatusCell: UICollectionViewCell {
    static let reuseIdentifier = "SurveyStatusCell"
    
    private let circleView = UIView()
    private let dateLabel = UILabel()
    private let moodLabel = UILabel()
    private let energyLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.layer.cornerRadius = 20
        circleView.clipsToBounds = true

        dateLabel.font = AppFont.description
        dateLabel.textColor = AppColor.primaryText
        moodLabel.font = AppFont.description
        moodLabel.textColor = AppColor.primaryText
        energyLabel.font = AppFont.description
        energyLabel.textColor = AppColor.primaryText

        let infoStackView = UIStackView(arrangedSubviews: [dateLabel, moodLabel, energyLabel])
        infoStackView.axis = .vertical
        infoStackView.spacing = 4
        infoStackView.translatesAutoresizingMaskIntoConstraints = false

        let mainStackView = UIStackView(arrangedSubviews: [circleView, infoStackView])
        mainStackView.axis = .horizontal
        mainStackView.alignment = .center
        mainStackView.spacing = 12
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStackView)
        contentView.backgroundColor = AppColor.backgroundColorCard
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4

        NSLayoutConstraint.activate([
            circleView.widthAnchor.constraint(equalToConstant: 40),
            circleView.heightAnchor.constraint(equalToConstant: 40),

            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }
    
    /// Configure cell with a SurveyDayStatus
    func configure(with status: SurveyDayStatus) {
        // Set circle color based on completion
        circleView.backgroundColor = status.completed ? AppColor.successColor : AppColor.errorColor
        
        // Format date as localized full weekday
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEEE dd/MM"
        let formatted = formatter.string(from: status.date)
        dateLabel.text = formatted.prefix(1).capitalized + formatted.dropFirst()

        if status.completed {
            moodLabel.text = "Umore: \(status.mood ?? 0)"
            energyLabel.text = "Energia: \(status.energy ?? 0)"
        } else {
            moodLabel.text = "Non compilato"
            energyLabel.text = ""
        }
    }
    
}
