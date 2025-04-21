//
//  MetricInfoView.swift
//  StatusApp
//
//  Created by Area mobile on 19/04/25.
//


import UIKit
import Lottie

/// View che gestisce la UI della schermata “Info metrica”,
/// inclusi Lottie e descrizione.
class MetricInfoView: UIView {
    // MARK: - Subviews

    private let mainStackView = UIStackView()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let titleLabel = UILabel()
    private let animationView = LottieAnimationView()
    private let descriptionView = UITextView()

    // MARK: - Metric

    private let metric: HealthMetric

    // MARK: - Init

    init(metric: HealthMetric) {
        self.metric = metric
        super.init(frame: .zero)
        backgroundColor = AppColor.backgroundColor
        setupLayout()
        configure(with: metric)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setupLayout() {
        // Main stack
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Title
        titleLabel.font = AppFont.info
        titleLabel.textColor = AppColor.primaryText
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        mainStackView.addArrangedSubview(titleLabel)

        // Scroll container
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        mainStackView.addArrangedSubview(scrollView)

        // Content stack inside scroll
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.alignment = .center
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.APP_MARGIN),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.APP_MARGIN),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -Constants.APP_MARGIN * 2)
        ])

        // Animation view constraints
        animationView.loopMode = .loop
        animationView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalToConstant: 300),
            animationView.widthAnchor.constraint(equalTo: widthAnchor)
        ])

        // Description view
        descriptionView.isEditable = false
        descriptionView.isScrollEnabled = false
        descriptionView.backgroundColor = .clear
        descriptionView.textContainerInset = .zero
        descriptionView.textContainer.lineFragmentPadding = 0
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(descriptionView)
    }

    // MARK: - Configuration

    private func configure(with metric: HealthMetric) {
        titleLabel.text = metric.rawValue
        descriptionView.attributedText = metric.attributedDescription

        // Carica animazione Lottie
        let name = getLottieImageNameFor(metric: metric)
        if let animation = LottieAnimation.named(name) {
            animationView.animation = animation
            animationView.play()
        }
    }

    private func getLottieImageNameFor(metric: HealthMetric) -> String {
        switch metric {
        case .passi: return "steps_more_info"
        case .frequenzaCardiaca: return "bpm_more_info"
        case .hrv: return "hrv_more_info"
        case .distanza: return "walking_more_info"
        case .energiaAttiva: return "energy_more_info"
        case .sonno: return "sleep_more_info"
        case .mindful: return "mindfull_more_info"
        }
    }
}
