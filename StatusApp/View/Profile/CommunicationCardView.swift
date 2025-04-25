//
//  CommunicationCardView.swift
//  StatusApp
//
//  Created by Area mobile on 21/04/25.
//


import UIKit

class CommunicationCardView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("communications", comment: "")
        label.font = AppFont.info
        label.textColor = AppColor.primaryText
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("no_communications", comment: "")
        label.font = AppFont.detail
        label.textColor = AppColor.visualizzaColor
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // Stack centrale con messaggio
        let centerContainer = UIView()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        centerContainer.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerContainer.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerContainer.centerYAnchor)
        ])

        // Stack principale verticale
        let mainStack = UIStackView(arrangedSubviews: [titleLabel, centerContainer])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.alignment = .fill
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.APP_MARGIN),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])

        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12
    }

    /// Metodo per aggiornare la comunicazione
    func update(message: String?) {
        messageLabel.text = message?.isEmpty == false ? message : NSLocalizedString("no_communications", comment: "")
    }
}
