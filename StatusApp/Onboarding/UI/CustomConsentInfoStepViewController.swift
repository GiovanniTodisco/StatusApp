//
//  CustomConsentInfoStepViewController.swift
//  StatusApp
//
//  Created by Area mobile on 05/04/25.
//


import UIKit
import ResearchKit
import Lottie

class CustomConsentInfoStepViewController: ORKStepViewController {
    
    private var animationView: LottieAnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.cancelButtonItem = nil
        setupCustomLayout()
    }

    override func goForward() {
        super.goForward()
    }

    private func setupCustomLayout() {
        //view.backgroundColor = AppColor.cardBackground
        
        let pageTitleLabel = UILabel()
        pageTitleLabel.text = NSLocalizedString("consent_intro_title", comment: "")
        pageTitleLabel.font = AppFont.titleIntro
        pageTitleLabel.textAlignment = .center
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageTitleLabel)

        NSLayoutConstraint.activate([
            pageTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            pageTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pageTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.spacing = 20
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        let sections = OnboardingConstants.consentSectionKeys.map {
            (NSLocalizedString($0.titleKey, comment: ""), NSLocalizedString($0.contentKey, comment: ""))
        }
        
        for (title, text) in sections {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = AppFont.title
            titleLabel.numberOfLines = 0

            let descriptionLabel = UILabel()
            descriptionLabel.text = text
            descriptionLabel.font = AppFont.description
            descriptionLabel.numberOfLines = 0

            contentView.addArrangedSubview(titleLabel)
            contentView.addArrangedSubview(descriptionLabel)
        }

        let continueButton = UIButton(type: .system)
        continueButton.setTitle(NSLocalizedString("btn_continue", comment: ""), for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.titleLabel?.font = AppFont.button
        continueButton.backgroundColor = AppColor.dark
        continueButton.layer.cornerRadius = 10
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(goForwardAction), for: .touchUpInside)
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -54),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    @objc private func goForwardAction() {
        self.goForward()
    }
}
