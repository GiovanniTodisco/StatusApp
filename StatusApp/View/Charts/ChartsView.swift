//
//  ChartsView.swift
//  StatusApp
//
//  Created by Area mobile on 19/04/25.
//

import UIKit
import DGCharts

/// Delegate protocol for chart view interactions (e.g., info taps)
protocol ChartsViewDelegate: AnyObject {}

/// UIView that manages all chart UI: scroll, stack, individual chart creation
class ChartsView: UIView {
    weak var delegate: ChartsViewDelegate?
    
    private let referenceValues: [String: Double]
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    /// Initialize with sample reference values for limit lines
    init(referenceValues: [String: Double]) {
        self.referenceValues = referenceValues
        super.init(frame: .zero)
        backgroundColor = AppColor.backgroundColor
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Set up scrollView and stackView layout
    private func setupLayout() {
        // scrollView fills safe area
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // stackView inside scrollView
        scrollView.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = Constants.APP_MARGIN * 3
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.APP_MARGIN),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.APP_MARGIN),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.APP_MARGIN),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Constants.APP_MARGIN),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -Constants.APP_MARGIN * 2)
        ])
    }
    
    /// Populate the view with chart views for each metric
    func update(with metrics: [HealthMetricData], skipEmpty: Bool) {
        // Clear old charts
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        // Add new ones
        for metricData in metrics {
            print("Sto creando il grafico per: \(metricData.metric.rawValue)")
            
            let numericEntries = metricData.values.compactMap {
                Double($0.value.components(separatedBy: .whitespaces).first ?? "")
            }
            if numericEntries.isEmpty && skipEmpty {
                continue
            }
            let chartView = createChartView(
                for: metricData.metric,
                with: metricData.values.map { (value: $0.value, dateString: $0.date) },
                showReferenceLine: true,
                skipEmpty: skipEmpty
            )
            stackView.addArrangedSubview(chartView)
        }
    }
    
    // MARK: - Chart Helpers
    
    public func createChartView(
        for metric: HealthMetric,
        with values: [(value: String, dateString: String)],
        showReferenceLine: Bool,
        skipEmpty: Bool
    ) -> UIView {
        var entries: [BarChartDataEntry] = []
        var labels: [String] = []
        
        for (index, dataPoint) in values.enumerated() {
            if let y = Double(dataPoint.value.components(separatedBy: .whitespaces).first ?? "") {
                entries.append(BarChartDataEntry(x: Double(index), y: y))
                labels.append(dataPoint.dateString)
            }
        }
        
        if entries.isEmpty {
            return makeEmptyChartView(for: metric.rawValue)
        }
        
        let chartView: ChartViewBase
        switch metric {
        case .passi, .distanza:
            chartView = createHorizontalBarChart(entries: entries, labels: labels, metric: metric)
        case .frequenzaCardiaca, .hrv:
            chartView = createLineChart(entries: entries, labels: labels, metric: metric)
        default:
            chartView = createDefaultBarChart(entries: entries, labels: labels, metric: metric)
        }
        
        if showReferenceLine {
            configureReferenceLine(for: chartView, metric: metric)
        }
        
        return wrapChartWithTitle(chartView, title: metric.rawValue, unitMetric: metric.unit)
    }
    
    private func configureReferenceLine(for chartView: ChartViewBase, metric: HealthMetric) {
        guard let ref = referenceValues[metric.rawValue],
              let base = chartView as? BarLineChartViewBase else { return }
        let limit = ChartLimitLine(limit: ref, label: NSLocalizedString("mid_reference", comment: ""))
        limit.lineColor = .systemRed
        limit.lineWidth = 1
        limit.lineDashLengths = [6, 3]
        limit.valueFont = AppFont.italicInfo
        limit.valueTextColor = AppColor.primaryText
        switch metric {
        case .passi, .distanza:
            limit.labelPosition = .leftBottom
        default:
            limit.labelPosition = .leftTop
        }
        base.leftAxis.addLimitLine(limit)
    }
    
    private func createHorizontalBarChart(entries: [BarChartDataEntry], labels: [String], metric: HealthMetric) -> BarChartView {
        let chart = HorizontalBarChartView()
        let set = BarChartDataSet(entries: entries)
        set.colors = [metric.color]
        chart.data = BarChartData(dataSet: set)
        chart.legend.enabled = false
        configureCommon(chart: chart, labels: labels)
        return chart
    }
    
    private func createLineChart(entries: [BarChartDataEntry], labels: [String], metric: HealthMetric) -> LineChartView {
        let chart = LineChartView()
        let set = LineChartDataSet(entries: entries)
        set.colors = [metric.color]
        set.circleColors = [metric.color]
        set.valueTextColor = AppColor.primaryText
        set.mode = .linear
        set.drawFilledEnabled = true
        set.fillAlpha = 0.5
        set.fillColor = metric.color
        set.drawCirclesEnabled = true
        set.circleRadius = 6.0
        chart.data = LineChartData(dataSet: set)
        chart.legend.enabled = false
        configureCommon(chart: chart, labels: labels)
        return chart
    }
    
    private func createDefaultBarChart(entries: [BarChartDataEntry], labels: [String], metric: HealthMetric) -> BarChartView {
        let chart = BarChartView()
        let set = BarChartDataSet(entries: entries)
        set.colors = [metric.color]
        chart.data = BarChartData(dataSet: set)
        chart.rightAxis.enabled = false
        chart.legend.enabled = false
        configureCommon(chart: chart, labels: labels)
        return chart
    }
    
    private func wrapChartWithTitle(_ chart: ChartViewBase, title: String, unitMetric: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AppFont.title
        titleLabel.textColor = AppColor.primaryText
        
        let infoLabel = UILabel()
        infoLabel.text = NSLocalizedString("last_7gg_data", comment: "")
        infoLabel.font = AppFont.info
        infoLabel.textColor = AppColor.primaryText
        infoLabel.numberOfLines = 0
        
        let unitLabel = UILabel()
        let text = String(format: NSLocalizedString("data_with_unit", comment: ""), unitMetric)
        let attr = NSMutableAttributedString(string: text)
        if let range = text.range(of: unitMetric) {
            attr.addAttribute(.font, value: AppFont.italicDescription, range: NSRange(range, in: text))
        }
        unitLabel.attributedText = attr
        unitLabel.textColor = AppColor.primaryText
        unitLabel.numberOfLines = 0
        
        let container = UIStackView(arrangedSubviews: [titleLabel, chart, infoLabel, unitLabel])
        container.axis = .vertical
        container.spacing = 8
        container.setCustomSpacing(4, after: infoLabel)
        return container
    }
    
    private func makeEmptyChartView(for metric: String) -> UIView {
        let label = UILabel()
        label.text = String(format: NSLocalizedString("no_data", comment: ""), metric)
        label.font = AppFont.info
        label.textColor = AppColor.primaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        image.tintColor = AppColor.primaryIcon
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIView()
        container.addSubview(image)
        container.addSubview(label)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            image.topAnchor.constraint(equalTo: container.topAnchor, constant: 32),
            image.heightAnchor.constraint(equalToConstant: 40),
            image.widthAnchor.constraint(equalToConstant: 40),
            
            label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: Constants.APP_MARGIN),
            label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -Constants.APP_MARGIN),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Constants.APP_MARGIN)
        ])
        return container
    }
    
    private func configureCommon(chart: BarLineChartViewBase, labels: [String]) {
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.heightAnchor.constraint(equalToConstant: 300).isActive = true
        chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        chart.xAxis.granularity = 1
        chart.xAxis.labelPosition = .bottom
        chart.setExtraOffsets(left: 0, top: 16, right: 16, bottom: 0)
        
        chart.leftAxis.drawGridLinesEnabled = false
        chart.rightAxis.enabled = false
        chart.xAxis.drawGridLinesEnabled = false
        
        chart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeOutQuart)
    }
}
