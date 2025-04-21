//
//  ChartsViewController.swift
//  StatusApp
//
//  Created by Area mobile on 06/04/25.
//

import UIKit
import DGCharts

class ChartsViewController: UIViewController, Loadable {
    private let referenceValues: [String: Double] = [
        HealthMetric.passi.rawValue: 7000,
        HealthMetric.frequenzaCardiaca.rawValue: 80,
        HealthMetric.hrv.rawValue: 60,
        HealthMetric.distanza.rawValue: 6000,
        HealthMetric.energiaAttiva.rawValue: 600,
        HealthMetric.sonno.rawValue: 7,
        HealthMetric.mindful.rawValue: 1
    ]
    private var chartsView: ChartsView!

    override func loadView() {
        chartsView = ChartsView(referenceValues: referenceValues)
        chartsView.delegate = self
        view = chartsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("charts", comment: "")
    }

    func loadData() async throws {
        let preferences = ChartsPreferencesManager.load()
        let metrics = try await HealthKitManager.shared.fetchHealthData(for: preferences)
        self.loadViewIfNeeded()
        await MainActor.run {
            chartsView.update(with: metrics, skipEmpty: true)
        }
    }
}

extension ChartsViewController: ChartsViewDelegate {}
