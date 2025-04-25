//
//  HomeView.swift
//  StatusApp
//
//  Created by Area mobile on 19/04/25.
//

import UIKit

protocol HomeViewDelegate: AnyObject {
    func homeView(_ homeView: HomeView, didTapCardFor metric: HealthMetric)
}

/// La UIView che gestisce tutta la UI della schermata “Home”
/// (scroll, welcome, data‑sharing, cards)
class HomeView: UIView {
    // MARK: - Subviews

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var dataSharingStack = UIStackView()

    /// Esposte al controller per le animazioni
    let welcomeLabel = UILabel()
    let subtitleLabel = UILabel()
    let dataSharingImage = UIImageView()
    let dataSharingTitleLabel = UILabel()
    let dataSharingStatusLabel = UILabel()
    
    weak var delegate: HomeViewDelegate?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AppColor.backgroundColor
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setupLayout() {
        // 1) Aggiungi e vincola lo scrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = AppColor.backgroundColor
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // 2) Configura stackView dentro scrollView
        stackView.axis = .vertical
        stackView.spacing = Constants.APP_MARGIN
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.APP_MARGIN / 2),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.APP_MARGIN),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.APP_MARGIN),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -Constants.APP_MARGIN * 2)
        ])

        // 3) Welcome label
        if let profile = UserProfile.load() {
            welcomeLabel.text = String(format: NSLocalizedString("welcome", comment: ""),
                                      profile.firstName)
        } else {
            welcomeLabel.text = NSLocalizedString("welcome", comment: "")
        }
        welcomeLabel.font = AppFont.welcome
        welcomeLabel.textColor = AppColor.primaryText
        welcomeLabel.textAlignment = .left
        welcomeLabel.numberOfLines = 0
        stackView.addArrangedSubview(welcomeLabel)

        // 4) Data sharing status
        let isShared = UserDefaults.standard.bool(forKey: Constants.ONBOARDING_COMPLETED_KEY)
        dataSharingImage.image = UIImage(systemName: isShared ? "checkmark.circle" : "xmark.circle")
        dataSharingImage.tintColor = isShared ? .systemGreen : .systemRed
        dataSharingImage.translatesAutoresizingMaskIntoConstraints = false
        dataSharingImage.widthAnchor.constraint(equalToConstant: 32).isActive = true
        dataSharingImage.heightAnchor.constraint(equalToConstant: 32).isActive = true

        dataSharingTitleLabel.text = NSLocalizedString("data_sharing", comment: "")
        dataSharingTitleLabel.font = AppFont.info
        dataSharingTitleLabel.textColor = isShared ? AppColor.successColor : AppColor.errorColor
        dataSharingTitleLabel.numberOfLines = 1

        dataSharingStatusLabel.text = isShared
            ? NSLocalizedString("active", comment: "")
            : NSLocalizedString("not_active", comment: "")
        dataSharingStatusLabel.font = AppFont.description
        dataSharingStatusLabel.textColor = isShared ? AppColor.successColor : AppColor.errorColor
        dataSharingStatusLabel.numberOfLines = 1

        let labelsStack = UIStackView(arrangedSubviews: [dataSharingTitleLabel, dataSharingStatusLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 0
        labelsStack.alignment = .leading
        labelsStack.translatesAutoresizingMaskIntoConstraints = false

        dataSharingStack = UIStackView(arrangedSubviews: [dataSharingImage, labelsStack])
        dataSharingStack.axis = .horizontal
        dataSharingStack.spacing = 8
        dataSharingStack.alignment = .center
        dataSharingStack.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(dataSharingStack)

        // 5) Subtitle label
        subtitleLabel.text = NSLocalizedString("result_today_msg", comment: "")
        subtitleLabel.font = AppFont.description
        subtitleLabel.textColor = AppColor.primaryText
        subtitleLabel.textAlignment = .left
        subtitleLabel.numberOfLines = 0
        stackView.addArrangedSubview(subtitleLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: Constants.APP_MARGIN,
            right: 0
        )
    }

    // MARK: - Update Content

    /// Aggiorna le “card” dei dati sanitari
    func update(with items: [HealthDataModel]) {
        let staticCount = 3
        let allSubviews = stackView.arrangedSubviews
        for idx in (staticCount..<allSubviews.count).reversed() {
            let viewToRemove = allSubviews[idx]
            stackView.removeArrangedSubview(viewToRemove)
            viewToRemove.removeFromSuperview()
        }

        // Aggiungi una card per ciascun modello
        for data in items {
            let card = createHealthCard(for: data)
            stackView.addArrangedSubview(card)
        }
    }

    // MARK: - Helpers

    private func createHealthCard(for data: HealthDataModel) -> UIView {
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = AppColor.backgroundColorCard
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        cardView.layer.shadowOpacity = 0.4
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4

        // Altezza fissa, lascia che sia il stackView ad adattarne la larghezza
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.20)
        ])

        // Icona
        let iconImageView = UIImageView(image: UIImage(systemName: data.iconName))
        iconImageView.tintColor = data.metric.color
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        // Titolo / Data / Valore
        let titleLabel = UILabel()
        titleLabel.text = data.title
        titleLabel.font = AppFont.title
        titleLabel.textColor = data.metric.color
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let dateLabel = UILabel()
        dateLabel.text = data.date
        dateLabel.font = AppFont.description
        dateLabel.textColor = AppColor.primaryText
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = data.value
        valueLabel.font = AppFont.description
        valueLabel.textColor = AppColor.primaryText
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

       
        let viewLabel = UILabel()
        viewLabel.text = NSLocalizedString("visualizza", comment: "")
        viewLabel.font = AppFont.description
        viewLabel.textColor = AppColor.visualizzaColor
        viewLabel.translatesAutoresizingMaskIntoConstraints = false

        let arrowImage = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImage.tintColor = AppColor.visualizzaColor
        arrowImage.translatesAutoresizingMaskIntoConstraints = false
        arrowImage.contentMode = .scaleAspectFit

        let viewStack = UIStackView(arrangedSubviews: [viewLabel, arrowImage])
        viewStack.axis = .horizontal
        viewStack.spacing = 2
        viewStack.alignment = .center
        viewStack.translatesAutoresizingMaskIntoConstraints = false

        // → Contenitore che spinge viewStack a destra
        let trailingContainer = UIStackView(arrangedSubviews: [UIView(), viewStack])
        trailingContainer.axis = .horizontal
        trailingContainer.alignment = .fill
        trailingContainer.distribution = .fill
        trailingContainer.translatesAutoresizingMaskIntoConstraints = false

        // Ora mettiamo tutto nel textStack: titolo, data, valore, e in fondo il trailingContainer
        let textStack = UIStackView(arrangedSubviews: [
          titleLabel,
          dateLabel,
          valueLabel,
          trailingContainer
        ])
        textStack.axis = .vertical
        textStack.spacing = 8
        textStack.alignment = .fill    // importante: full width
        textStack.translatesAutoresizingMaskIntoConstraints = false

        // Main stack: icona a sinistra, testo a destra
        let mainStack = UIStackView(arrangedSubviews: [iconImageView, textStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            mainStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            mainStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])

        // Enable tap detection
        cardView.isUserInteractionEnabled = true
        cardView.tag = data.metric.hashValue
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(_:)))
        cardView.addGestureRecognizer(tap)

        return cardView
    }

    @objc private func handleCardTap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        let hash = view.tag
        if let metric = HealthMetric.allCases.first(where: { $0.hashValue == hash }) {
            delegate?.homeView(self, didTapCardFor: metric)
        }
    }
}
