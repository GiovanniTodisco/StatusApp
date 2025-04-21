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
    private var homeView: HomeView!
    private var healthDataItems: [HealthDataModel] = []

    // MARK: - Loadable
    func loadData() async throws {
        let healthKitManager = HealthKitManager.shared
        healthDataItems = try await healthKitManager.fetchLatestHealthData()
        DispatchQueue.main.async {
            self.homeView.update(with: self.healthDataItems)
        }
    }

    // MARK: - Lifecycle
    override func loadView() {
        homeView = HomeView()
        homeView.delegate = self
        view = homeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
    }
}

extension HomeViewController: HomeViewDelegate {
    func homeView(_ homeView: HomeView, didTapCardFor metric: HealthMetric) {
        guard let tabBar = tabBarController as? MainTabBarController else { return }
        tabBar.selectedIndex = 1
        if let chartsNav = tabBar.viewControllers?[1] as? UINavigationController {
            let detailVC = ChartDetailViewController(metric: metric)
            chartsNav.popToRootViewController(animated: false)
            chartsNav.pushViewController(detailVC, animated: true)
        }
    }
}
