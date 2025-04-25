//
//  ChartDetailView.swift
//  StatusApp
//
//  Created by Area mobile on 19/04/25.
//

import UIKit

/// Delegate per notificare i cambi di range e il tap sul bottone info
protocol ChartDetailViewDelegate: AnyObject {
    func chartDetailView(_ view: ChartDetailView, didChangeRange range: TimeRange)
    func chartDetailViewDidTapInfo(_ view: ChartDetailView)
}

/// Vista che contiene il segmented control, il container del grafico e il bottone “Scopri di più”
class ChartDetailView: UIView {
    weak var delegate: ChartDetailViewDelegate?
    private let metric: HealthMetric

    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Giorno", "Settimana", "Mese"])
        sc.selectedSegmentIndex = 1
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let chartContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let infoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(NSLocalizedString("find_out_more", comment: ""), for: .normal)
        btn.titleLabel?.font = AppFont.button
        btn.setTitleColor(AppColor.primaryText, for: .normal)
        btn.backgroundColor = AppColor.primaryIcon
        btn.layer.cornerRadius = 10
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Init

    init(metric: HealthMetric) {
        self.metric = metric
        super.init(frame: .zero)
        backgroundColor = AppColor.backgroundColor
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout

    private func setupLayout() {
        addSubview(segmentedControl)
        addSubview(chartContainer)
        addSubview(infoButton)

        NSLayoutConstraint.activate([
            // Segmented Control
            segmentedControl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // Chart Container
            chartContainer.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            chartContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            chartContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chartContainer.bottomAnchor.constraint(lessThanOrEqualTo: infoButton.topAnchor, constant: -16),

            // Info Button
            infoButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -54),
            infoButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            infoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            infoButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    // MARK: - Actions

    private func setupActions() {
        segmentedControl.addTarget(self, action: #selector(rangeChanged(_:)), for: .valueChanged)
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
    }

    // MARK: - Public API

    /// Popola il container con il grafico attuale
    func displayChart(values: [(value: String, date: String)], showReferenceLine: Bool) {
        // Svuota il container
        chartContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // Crea il graph view da ChartsViewController
        let chartVC = ChartsView(referenceValues: [:])
        let chartView = chartVC.createChartView(
            for: metric,
            with: values.map { (value: $0.value, dateString: $0.date) },
            showReferenceLine: showReferenceLine,
            skipEmpty: false
        )
        chartContainer.addArrangedSubview(chartView)
    }

    // MARK: - Callbacks

    @objc private func rangeChanged(_ sender: UISegmentedControl) {
        let range: TimeRange
        switch sender.selectedSegmentIndex {
        case 0: range = .day
        case 1: range = .week
        case 2: range = .month
        default: range = .week
        }
        delegate?.chartDetailView(self, didChangeRange: range)
    }

    @objc private func infoTapped() {
        delegate?.chartDetailViewDidTapInfo(self)
    }
}
