//
//  ProfileViewController.swift
//  StatusApp
//
//  Created by Area mobile on 06/04/25.
//


import UIKit

class ProfileViewController: UIViewController, ConsentStatusCardViewDelegate, ProfileSummaryViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.backgroundColor
        title = NSLocalizedString("profile", comment: "")
        setupLayout()
    }
    
    private func setupLayout() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        // Sezione Profilo
        let profileSummary = ProfileSummaryView()
        profileSummary.delegate = self
        profileSummary.applyCardStyle(height: UIScreen.main.bounds.height * 0.20)
        stack.addArrangedSubview(profileSummary)

        // Stato Consenso
        let consentCard = ConsentStatusCardView()
        consentCard.applyCardStyle(height: UIScreen.main.bounds.height * 0.20)
        consentCard.delegate = self
        stack.addArrangedSubview(consentCard)

        // Comunicazioni
        let communicationsCard = CommunicationCardView()
        communicationsCard.applyCardStyle(height: UIScreen.main.bounds.height * 0.20)
        stack.addArrangedSubview(communicationsCard)

        // Spacer
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        stack.addArrangedSubview(spacer)

        let logoutButton = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.title = NSLocalizedString("log_out", comment: "")
        config.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseForegroundColor = AppColor.primaryIcon // Icona e testo

        logoutButton.configuration = config
        logoutButton.titleLabel?.font = AppFont.button
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.contentHorizontalAlignment = .leading
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)

        view.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 24),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logoutButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
    }

    @objc private func logoutTapped() {
        // Logica di logout
        print("Log out tapped")
    }

    func didTapConsentCard() {
        let detailVC = ConsentDetailViewController()
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func didTapProfileCard() {
        let detailVC = ProfileDetailViewController()
        navigationController?.pushViewController(detailVC, animated: true)
    }
}


extension UIView {
    func applyCardStyle(height: CGFloat? = nil) {
        backgroundColor = AppColor.backgroundColorCard
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        translatesAutoresizingMaskIntoConstraints = false

        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
