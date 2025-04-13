//
//  HealthCardCell.swift
//  StatusApp
//
//  Created by Area mobile on 07/04/25.
//


import UIKit

class HealthCardCell: UICollectionViewCell {
    let iconView = UIImageView()
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    let valueLabel = UILabel()
    let arrowView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = AppColor.backgroundColorCard
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 4

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = AppColor.primaryIcon

        titleLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor = AppColor.primaryText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = .gray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        valueLabel.textColor = AppColor.primaryText
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        arrowView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.image = UIImage(systemName: "flame.fill")
        arrowView.tintColor = .red
        arrowView.contentMode = .scaleAspectFit

        let contentStack = UIStackView(arrangedSubviews: [iconView, titleLabel, dateLabel, valueLabel, arrowView])
        contentStack.axis = .horizontal
        contentStack.spacing = 8
        contentStack.alignment = .center
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            iconView.widthAnchor.constraint(equalToConstant: 30),
            iconView.heightAnchor.constraint(equalToConstant: 30),
            arrowView.widthAnchor.constraint(equalToConstant: 20)
        ])
    }

    func configure(icon: UIImage?, title: String, date: String, value: String) {
        iconView.image = icon
        titleLabel.text = title
        dateLabel.text = date
        valueLabel.text = value
    }
}
