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
        
        self.cancelButtonItem = nil
        setupCustomLayout()
    }

    private func setupCustomLayout() {
        //view.backgroundColor = AppColor.cardBackground
        
        // Titolo custom
        let appTitle = UILabel()
        appTitle.text = NSLocalizedString("app_name", comment: "")
        appTitle.font = AppFont.appName
        appTitle.textAlignment = .center
        appTitle.textColor = AppColor.accentCoral
        appTitle.numberOfLines = 0
        appTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appTitle)
        
        // Titolo custom
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("welcome_title", comment: "")
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
        descriptionLabel.text = NSLocalizedString("welcome_msg", comment: "")
        descriptionLabel.font = AppFont.description
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)

        
        internalContinueButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font : AppFont.button], for: .normal)
        internalContinueButtonItem?.title = NSLocalizedString("btn_continue", comment: "")

        NSLayoutConstraint.activate([
            // Titolo in alto
            appTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.bounds.height * 0.001),
            appTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.07),
            appTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.bounds.width * 0.07),

            // Immagine o animazione sotto titolo
            animationView!.topAnchor.constraint(equalTo: appTitle.bottomAnchor, constant: view.bounds.height * 0.1),
            animationView!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView!.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            animationView!.heightAnchor.constraint(equalTo: animationView!.widthAnchor),

            // Titolo sotto animazione
            titleLabel.topAnchor.constraint(equalTo: animationView!.bottomAnchor, constant: view.bounds.height * 0.03),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.07),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.bounds.width * 0.07),

            // Descrizione sotto titolo
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: view.bounds.height * 0.015),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.07),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.bounds.width * 0.07)
        ])
    }
}
