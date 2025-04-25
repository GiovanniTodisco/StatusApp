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
        var _: [HealthMetricData] = healthDataItems.map {
            HealthMetricData(metric: $0.metric, values: [MetricValue(date: $0.date, value: $0.value)])
        }
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            let healthKitManager = HealthKitManager.shared
            let latestItems = try? await healthKitManager.fetchLatestHealthData()
            if let items = latestItems {
                let mapped = items.map {
                    HealthMetricData(metric: $0.metric, values: [MetricValue(date: $0.date, value: $0.value)])
                }
                HealthDataSyncService.shared.uploadAlways(metrics: mapped)
            }
        }
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
