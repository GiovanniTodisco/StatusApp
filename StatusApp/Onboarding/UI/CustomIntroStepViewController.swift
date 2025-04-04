//
//  CustomIntroStepViewController.swift
//  StatusApp
//
//  Created by Area mobile on 04/04/25.
//


import UIKit
import ResearchKit
import Lottie

class CustomIntroStepViewController: ORKInstructionStepViewController {
    
    private var animationView: LottieAnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomLayout()
    }

    private func setupCustomLayout() {
        view.backgroundColor = AppColor.cardBackground

        // Titolo custom
        let titleLabel = UILabel()
        titleLabel.text = step?.title
        titleLabel.font = AppFont.title
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Animazione Lottie
        if let animation = LottieAnimation.named("welcome") {
            let animationView = LottieAnimationView(animation: animation)
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop
            animationView.translatesAutoresizingMaskIntoConstraints = false
            animationView.play()
            view.addSubview(animationView)
            self.animationView = animationView
        }

        // Testo descrittivo
        let descriptionLabel = UILabel()
        descriptionLabel.text = step?.text
        descriptionLabel.font = AppFont.description
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)

        // 1. Bottone custom
        let continueButton = UIButton(type: .system)
        continueButton.setTitle("Continua", for: .normal)
        continueButton.titleLabel?.font = AppFont.button
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.backgroundColor = .systemBlue
        continueButton.layer.cornerRadius = 10
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            // Immagine o animazione centrata
            animationView!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView!.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            animationView!.widthAnchor.constraint(equalToConstant: 250),
            animationView!.heightAnchor.constraint(equalToConstant: 250),

            // Titolo sotto animazione
            titleLabel.topAnchor.constraint(equalTo: animationView!.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            // Descrizione sotto titolo
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            // Bottone in basso
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 160),
            continueButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
