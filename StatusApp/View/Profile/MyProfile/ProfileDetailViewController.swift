//
//  ProfileDetailViewController.swift
//  StatusApp
//
//  Created by Area mobile on 21/04/25.
//

import UIKit

class ProfileDetailViewController: UIViewController {

    private let initialsView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.backgroundColorIcon
        view.layer.cornerRadius = 40
        view.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center

        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.title
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("profile", comment: "")
        view.backgroundColor = AppColor.backgroundColor
        setupLayout()
    }

    private func setupLayout() {
        guard let profile = UserProfile.load() else { return }

        let initials = "\(profile.firstName.prefix(1))\(profile.lastName.prefix(1))"
        initialsView.subviews.compactMap { $0 as? UILabel }.first?.text = initials.uppercased()
        
        nameLabel.text = "\(profile.firstName.trimmingCharacters(in: .whitespacesAndNewlines)) \(profile.lastName.trimmingCharacters(in: .whitespacesAndNewlines))"

        view.addSubview(initialsView)
        view.addSubview(nameLabel)

        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("form_title", comment: "")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)

        let editButton = UIButton(type: .system)
        editButton.setTitle(NSLocalizedString("edit", comment: ""), for: .normal)
        editButton.titleLabel?.font = AppFont.description
        editButton.setTitleColor(AppColor.primaryIcon, for: .normal)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)

        view.addSubview(editButton)

        let infoStackView = UIStackView()
        infoStackView.axis = .vertical
        infoStackView.backgroundColor = AppColor.backgroundColorCard
        infoStackView.layer.cornerRadius = 12
        infoStackView.layer.masksToBounds = true
        infoStackView.spacing = 24
        infoStackView.translatesAutoresizingMaskIntoConstraints = false

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = "dd/MM/yyyy"

        let profileData: [(String, String)] = [
            (NSLocalizedString("name", comment: ""), profile.firstName),
            (NSLocalizedString("surname", comment: ""), profile.lastName),
            (NSLocalizedString("form_birthdate", comment: ""), formatter.string(from: profile.birthDate)),
            (NSLocalizedString("form_height", comment: ""), profile.height),
            (NSLocalizedString("form_weight", comment: ""), profile.weight)
        ]

        for (index, (labelText, valueText)) in profileData.enumerated() {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel()
            label.text = labelText
            label.font = AppFont.info
            label.translatesAutoresizingMaskIntoConstraints = false

            let value = UILabel()
            value.text = valueText.isEmpty ? "-" : valueText
            value.font = AppFont.description
            value.textAlignment = .right
            value.translatesAutoresizingMaskIntoConstraints = false

            let separator = UIView()
            separator.backgroundColor = .systemGray4
            separator.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(label)
            container.addSubview(value)
            container.addSubview(separator)

            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                label.centerYAnchor.constraint(equalTo: container.centerYAnchor),

                value.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
                value.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                value.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                value.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
            
            if index < profileData.count - 1 {
                NSLayoutConstraint.activate([
                    separator.heightAnchor.constraint(equalToConstant: 1),
                    separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                    separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                    separator.bottomAnchor.constraint(equalTo: container.bottomAnchor)
                ])
            }

            infoStackView.addArrangedSubview(container)
        }

        view.addSubview(infoStackView)

        NSLayoutConstraint.activate([
            initialsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            initialsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initialsView.widthAnchor.constraint(equalToConstant: 80),
            initialsView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.topAnchor.constraint(equalTo: initialsView.bottomAnchor, constant: 12),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            editButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            infoStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            infoStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            infoStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            infoStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300)
        ])
    }
    
    @objc private func editButtonTapped() {
        let modal = EditMetricsViewController()
        modal.modalPresentationStyle = .pageSheet
        modal.delegate = self
        present(modal, animated: true)
    }
}

// MARK: - EditMetricsViewControllerDelegate
extension ProfileDetailViewController: EditMetricsViewControllerDelegate {
    func didUpdateMetrics() {
        view.subviews.forEach { $0.removeFromSuperview() }
        setupLayout()
    }
}
