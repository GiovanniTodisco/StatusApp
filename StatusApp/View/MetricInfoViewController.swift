//
//  MetricInfoViewController.swift
//  StatusApp
//
//  Created by Area mobile on 16/04/25.
//

import UIKit
import Lottie

class MetricInfoViewController: UIViewController {

    private let metric: HealthMetric

    init(metric: HealthMetric) {
        self.metric = metric
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.backgroundColor

        if let sheet = sheetPresentationController {
            sheet.detents = [.large()]
        }

        setupScrollView()
    }

    private func setupScrollView() {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let titleLabel = UILabel()
        titleLabel.text = metric.rawValue
        titleLabel.font = AppFont.info
        titleLabel.textColor = AppColor.primaryText
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.addArrangedSubview(titleLabel)

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        mainStackView.addArrangedSubview(scrollView)

        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.spacing = 20
        contentView.alignment = .center
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.APP_MARGIN),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.APP_MARGIN),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -Constants.APP_MARGIN * 2)
        ])

       
        guard let animation = LottieAnimation.named(self.getLottieImageNameFromMetric()) else { return }
        let animationView = LottieAnimationView(animation: animation)
        animationView.loopMode = .loop
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalToConstant: 300),
            animationView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        ])

        contentView.addArrangedSubview(animationView)
        
        let descriptionView = UITextView()
        descriptionView.isEditable = false
        descriptionView.isScrollEnabled = false
        descriptionView.backgroundColor = .clear
        descriptionView.textContainerInset = .zero
        descriptionView.textContainer.lineFragmentPadding = 0
        
        descriptionView.attributedText = metric.attributedDescription
        contentView.addArrangedSubview(descriptionView)
    }
    
    
    private func getLottieImageNameFromMetric() -> String {
        switch metric.rawValue {
            case HealthMetric.passi.rawValue: return "steps_more_info"
            case HealthMetric.frequenzaCardiaca.rawValue: return "bpm_more_info"
            case HealthMetric.hrv.rawValue: return "hrv_more_info"
            case HealthMetric.distanza.rawValue: return "walking_more_info"
            case HealthMetric.energiaAttiva.rawValue: return "energy_more_info"
            case HealthMetric.sonno.rawValue: return "sleep_more_info"
            case HealthMetric.mindful.rawValue: return "mindfull_more_info"
            default: return ""
        }
   
    }
}


