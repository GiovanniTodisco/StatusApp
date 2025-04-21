//
//  SurveyStatusCell.swift
//  StatusApp
//
//  Created by Area mobile on 21/04/25.
//

import UIKit

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
        moodLabel.font = AppFont.description
        energyLabel.font = AppFont.description

        dateLabel.textColor = .label
        moodLabel.textColor = .label
        energyLabel.textColor = .label

        let infoStack = UIStackView(arrangedSubviews: [dateLabel, moodLabel, energyLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 4
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        let mainStackView = UIStackView(arrangedSubviews: [circleView, infoStack])
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
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEEE dd/MM/yyyy"
        let formattedDate = formatter.string(from: status.date)
        dateLabel.text = formattedDate.prefix(1).capitalized + formattedDate.dropFirst()

        if status.completed {
            moodLabel.text = String(format: NSLocalizedString("survey_mood", comment: ""), status.mood ?? 0)
            energyLabel.text = String(format: NSLocalizedString("survey_energy", comment: ""), status.energy ?? 0)
        } else {
            moodLabel.text = NSLocalizedString("survey_not_filled", comment: "")
            energyLabel.text = ""
        }

        circleView.backgroundColor = status.completed ? AppColor.successColor : AppColor.errorColor
    }
    
}
