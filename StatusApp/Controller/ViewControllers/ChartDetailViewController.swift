//
//  ChartDetailViewController.swift
//  StatusApp
//
//  Created by Area mobile on 16/04/25.
//

import UIKit

/// Coordinatore del dettaglio grafico: si occupa solo di fetch e navigazione,
/// la UI vera sta in `ChartDetailView`.
class ChartDetailViewController: UIViewController, Loadable {
    private let metric: HealthMetric
    private var selectedRange: TimeRange = .week
    private var showReferenceLine = false
    private var detailView: ChartDetailView!

    // MARK: - Init

    init(metric: HealthMetric) {
        self.metric = metric
        super.init(nibName: nil, bundle: nil)
        title = metric.rawValue
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func loadView() {
        detailView = ChartDetailView(metric: metric)
        detailView.delegate = self
        view = detailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateChart()
    }

    // MARK: - Data Loading

    func loadData() async throws {
        // Se vuoi far partire il caricamento fin da subito via Loadable
        updateChart()
    }

    private func updateChart() {
        Task {
            let prefs = ChartsPreferences(
                selectedMetrics: [metric.rawValue],
                selectedTimeRange: selectedRange
            )
            let data = try await HealthKitManager.shared.fetchHealthData(for: prefs)
            guard let metricData = data.first(where: { $0.metric == metric }) else { return }
            await MainActor.run {
                detailView.displayChart(
                    values: metricData.values.map { (value: $0.value, date: $0.date) },
                    showReferenceLine: showReferenceLine
                )
            }
        }
    }
}

// MARK: - ChartDetailViewDelegate

extension ChartDetailViewController: ChartDetailViewDelegate {
    func chartDetailView(_ view: ChartDetailView, didChangeRange range: TimeRange) {
        selectedRange = range
        updateChart()
    }
    func chartDetailViewDidTapInfo(_ view: ChartDetailView) {
        let infoVC = MetricInfoViewController(metric: metric)
        present(infoVC, animated: true)
    }
}
