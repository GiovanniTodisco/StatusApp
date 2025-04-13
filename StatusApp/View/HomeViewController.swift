//
//  HomeViewController.swift
//  StatusApp
//
//  Created by Area mobile on 06/04/25.
//

import UIKit

struct HealthDataModel {
    let metric: HealthMetric
    let iconName: String
    let title: String
    let date: String
    let value: String
}

class HomeViewController: UIViewController, Loadable {
    
    private var healthDataItems: [HealthDataModel] = []
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let welcomeLabel = UILabel()
    private let subtitleLabel = UILabel()
    private var collectionView: UICollectionView!

    func loadData() async throws {
        let healthKitManager = HealthKitManager.shared
        healthDataItems = try await healthKitManager.fetchLatestHealthData()

        DispatchQueue.main.async {
            self.stackView.arrangedSubviews.forEach { view in
                if view != self.welcomeLabel && view != self.subtitleLabel {
                    self.stackView.removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
            }
            for item in self.healthDataItems {
                let card = self.createHealthCard(for: item)
                self.stackView.addArrangedSubview(card)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1.0) {
            self.welcomeLabel.alpha = 1
            self.subtitleLabel.alpha = 1
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearanceNav = UINavigationBarAppearance()
        appearanceNav.configureWithOpaqueBackground()
        
        appearanceNav.backgroundColor = AppColor.backgroundColor

        navigationController?.navigationBar.standardAppearance = appearanceNav
        navigationController?.navigationBar.scrollEdgeAppearance = appearanceNav
        
        view.backgroundColor = .systemBackground
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColor.backgroundColor
        navigationItem.largeTitleDisplayMode = .automatic // Changed line
        appearance.largeTitleTextAttributes = [.foregroundColor: AppColor.primaryText] // Added line

        title = "Home"
        
        navigationController?.navigationBar.prefersLargeTitles = true // Added line

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        self.setupUI()

        scrollView.backgroundColor = AppColor.backgroundColor
        stackView.backgroundColor = AppColor.backgroundColor
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = []
        
        scrollView.contentInset.bottom = Constants.APP_MARGIN
    }
    
    private func setupUI() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        stackView.axis = .vertical
        stackView.spacing = Constants.APP_MARGIN
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.APP_MARGIN / 2),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.APP_MARGIN),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.APP_MARGIN),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        if let profile = UserProfile.load() {
            welcomeLabel.text = String(format: NSLocalizedString("welcome", comment: ""), profile.firstName, profile.lastName)
        } else {
            welcomeLabel.text = NSLocalizedString("welcome", comment: "")
        }

        welcomeLabel.font = AppFont.welcome
        welcomeLabel.textColor = AppColor.primaryText
        welcomeLabel.textAlignment = .left
        welcomeLabel.numberOfLines = 0
        welcomeLabel.alpha = 0

        subtitleLabel.text = NSLocalizedString("result_today_msg", comment: "")
        subtitleLabel.font = AppFont.description
        subtitleLabel.textColor = AppColor.primaryText
        subtitleLabel.textAlignment = .left
        subtitleLabel.numberOfLines = 0
        subtitleLabel.alpha = 0
        
        stackView.addArrangedSubview(welcomeLabel)
        stackView.addArrangedSubview(subtitleLabel)
    }
    
    private func createHealthCard(for data: HealthDataModel) -> UIView {
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = AppColor.backgroundColorCard
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        cardView.layer.shadowOpacity = 0.4
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4

        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.2),
            cardView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - Constants.APP_MARGIN * 2)
        ])

        let iconImageView = UIImageView(image: UIImage(systemName: data.iconName))
        iconImageView.tintColor = data.metric.color
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit

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
        
        let visualizzaLabel = UILabel()
        visualizzaLabel.text = NSLocalizedString("visualizza", comment: "")
        visualizzaLabel.font = AppFont.description
        visualizzaLabel.textColor = AppColor.visualizzaColor
        visualizzaLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let iconArrowVisualizza = UIImageView(image: UIImage(systemName: "chevron.right"))
        iconArrowVisualizza.tintColor = AppColor.visualizzaColor
        iconArrowVisualizza.translatesAutoresizingMaskIntoConstraints = false
        iconArrowVisualizza.contentMode = .scaleAspectFit
        
        let horizontalStackVisualizza = UIStackView(arrangedSubviews: [visualizzaLabel, iconArrowVisualizza])
        horizontalStackVisualizza.axis = .horizontal
        horizontalStackVisualizza.spacing = 2
        horizontalStackVisualizza.alignment = .fill
        horizontalStackVisualizza.distribution = .equalCentering
        horizontalStackVisualizza.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackVisualizza.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let visualizzaContainer = UIStackView(arrangedSubviews: [UIView(), horizontalStackVisualizza])
        visualizzaContainer.axis = .horizontal
        visualizzaContainer.spacing = 0
        visualizzaContainer.alignment = .center
        visualizzaContainer.translatesAutoresizingMaskIntoConstraints = false

        let verticalStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel, valueLabel, visualizzaContainer])
        verticalStack.axis = .vertical
        verticalStack.spacing = 8
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalStack = UIStackView(arrangedSubviews: [iconImageView, verticalStack])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 12
        horizontalStack.alignment = .center
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(horizontalStack)

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),

            horizontalStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            horizontalStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            horizontalStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            horizontalStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])

        return cardView
    }
}
