//
//  ChartDetailViewController.swift
//  StatusApp
//
//  Created by Area mobile on 16/04/25.
//

import UIKit
import DGCharts

class ChartDetailViewController: UIViewController, Loadable {

    private let metric: HealthMetric
    private var selectedRange: TimeRange = .week
    private var showReferenceLine = false // Booleana per gestire la non visualizzazione della media campione nel case di dettaglio
    private let segmentedControl = UISegmentedControl(items: ["Giorno", "Settimana", "Mese"])
    private let chartContainer = UIStackView()

    private let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Scopri di più", for: .normal)
        button.titleLabel?.font = AppFont.primary
        button.setTitleColor(AppColor.primaryText, for: .normal)
        button.backgroundColor = AppColor.primaryIcon
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(metric: HealthMetric) {
        self.metric = metric
        super.init(nibName: nil, bundle: nil)
        self.title = metric.rawValue
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.backgroundColor
        setupUI()
        loadChartData()
    }

    func loadData() async throws {
        let preferences = ChartsPreferencesManager.load()
        let customPrefs = ChartsPreferences(
            selectedMetrics: [metric.rawValue],
            selectedTimeRange: preferences.selectedTimeRange
        )
        let metrics = try await HealthKitManager.shared.fetchHealthData(for: customPrefs)

        guard let metricData = metrics.first(where: { $0.metric == metric }) else { return }

        await MainActor.run {
            self.chartContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
            let chartVC = ChartsViewController()
            let chartView = chartVC.createChartView(for: metric, with: metricData.values.map { (value: $0.value, dateString: $0.date) }, showReferenceLine: self.showReferenceLine)
            self.chartContainer.addArrangedSubview(chartView)
        }
    }

    private func setupUI() {
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.addTarget(self, action: #selector(rangeChanged(_:)), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        chartContainer.axis = .vertical
        chartContainer.spacing = 16
        chartContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chartContainer)

        NSLayoutConstraint.activate([
            chartContainer.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            chartContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chartContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            chartContainer.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -16)
        ])

        view.addSubview(infoButton)
        infoButton.addTarget(self, action: #selector(showMetricInfo), for: .touchUpInside)

        NSLayoutConstraint.activate([
            infoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -54),
            infoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            infoButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    @objc private func rangeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0: selectedRange = .day
            case 1: selectedRange = .week
            case 2: selectedRange = .month
            default: selectedRange = .week
        }
        loadChartData()
    }

    private func loadChartData() {
        Task {
            let preferences = ChartsPreferences(
                selectedMetrics: [metric.rawValue],
                selectedTimeRange: selectedRange
            )
            let data = try await HealthKitManager.shared.fetchHealthData(for: preferences)
            guard let metricData = data.first(where: { $0.metric == metric }) else { return }

            DispatchQueue.main.async {
                self.chartContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
                let chartVC = ChartsViewController()
                let chartView = chartVC.createChartView(for: self.metric, with: metricData.values.map {
                    (value: $0.value, dateString: $0.date)
                }, showReferenceLine: self.showReferenceLine)
                self.chartContainer.addArrangedSubview(chartView)
            }
        }
    }

    @objc private func showMetricInfo() {
        let infoVC = MetricInfoViewController(metric: metric)
        present(infoVC, animated: true)
    }
}
