//
//  HomeViewController.swift
//  StatusApp
//
//  Created by Area mobile on 06/04/25.
//

import UIKit

struct HealthDataModel {
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
        
        appearanceNav.backgroundColor = AppColor.cardBackground

        navigationController?.navigationBar.standardAppearance = appearanceNav
        navigationController?.navigationBar.scrollEdgeAppearance = appearanceNav
        
        view.backgroundColor = AppColor.cardBackground
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColor.cardBackground
        navigationItem.largeTitleDisplayMode = .automatic // Changed line
        appearance.largeTitleTextAttributes = [.foregroundColor: AppColor.dark] // Added line

        title = "Home"
        
        navigationController?.navigationBar.prefersLargeTitles = true // Added line

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        self.setupUI()

        scrollView.backgroundColor = AppColor.cardBackground
        stackView.backgroundColor = .clear
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

        welcomeLabel.font = AppFont.title
        welcomeLabel.textColor = AppColor.dark
        welcomeLabel.textAlignment = .left
        welcomeLabel.numberOfLines = 0
        welcomeLabel.alpha = 0

        subtitleLabel.text = NSLocalizedString("result_today_msg", comment: "")
        subtitleLabel.font = AppFont.description
        subtitleLabel.textColor = AppColor.dark
        subtitleLabel.textAlignment = .left
        subtitleLabel.numberOfLines = 0
        subtitleLabel.alpha = 0
        
        stackView.addArrangedSubview(welcomeLabel)
        stackView.addArrangedSubview(subtitleLabel)
    }
    
    private func createHealthCard(for data: HealthDataModel) -> UIView {
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = AppColor.cardBackground
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4

        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.2),
            cardView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - Constants.APP_MARGIN * 2)
        ])

        let iconImageView = UIImageView(image: UIImage(systemName: data.iconName))
        iconImageView.tintColor = AppColor.primary
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = data.title
        titleLabel.font = AppFont.title
        titleLabel.textColor = AppColor.dark
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let dateLabel = UILabel()
        dateLabel.text = data.date
        dateLabel.font = AppFont.primary
        dateLabel.textColor = AppColor.dark
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = data.value
        valueLabel.font = AppFont.primary
        valueLabel.textColor = AppColor.dark
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        let verticalStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel, valueLabel])
        verticalStack.axis = .vertical
        verticalStack.spacing = 4
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

            horizontalStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            horizontalStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            horizontalStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            horizontalStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])

        return cardView
    }
}
