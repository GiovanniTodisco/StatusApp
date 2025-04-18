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
        HealthMetric.passi.rawValue: 7000, //numero di passi
        HealthMetric.frequenzaCardiaca.rawValue: 80, //bpm
        HealthMetric.hrv.rawValue: 60, //millis
        HealthMetric.distanza.rawValue: 6000, //metri
        HealthMetric.energiaAttiva.rawValue: 600 ,//kcal
        HealthMetric.sonno.rawValue: 7, //ore
        HealthMetric.mindful.rawValue: 1 //min
    ]
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColor.backgroundColor
        title = NSLocalizedString("charts", comment: "")
        
        setupStackView()
    }

    private func setupStackView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        stackView.axis = .vertical
        stackView.spacing = Constants.APP_MARGIN*2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    func loadData() async throws {
        let preferences = ChartsPreferencesManager.load()
        let metrics = try await HealthKitManager.shared.fetchHealthData(for: preferences)

        DispatchQueue.main.async {
            self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        }

        for metricData in metrics {
            print("Sto creando il grafico per: \(metricData.metric.rawValue)")
            let chartView = createChartView(for: metricData.metric, with: metricData.values.map { (value: $0.value, dateString: $0.date) }, showReferenceLine:true)
            DispatchQueue.main.async {
                self.stackView.addArrangedSubview(chartView)
            }
        }
    }

    internal func createChartView(for metric: HealthMetric, with values: [(value: String, dateString: String)], showReferenceLine: Bool) -> UIView {
        var entries: [BarChartDataEntry] = []
        var labels: [String] = []

        for (index, dataPoint) in values.enumerated() {
            if let value = Double(dataPoint.value.components(separatedBy: CharacterSet.whitespaces).first ?? "") {
                entries.append(BarChartDataEntry(x: Double(index), y: value))
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
            //setup valore campion
            configureReferenceLine(for: chartView, metric: metric)
        }
        
        return wrapChartWithTitle(chartView, title: metric.rawValue, unitMetric: metric.unit)
    }
    
    private func configureReferenceLine(for chartView: ChartViewBase, metric: HealthMetric) {
        guard let riferimento = referenceValues[metric.rawValue],
              let chart = chartView as? BarLineChartViewBase else { return }

        let lineaCampione = ChartLimitLine(limit: riferimento, label: NSLocalizedString("mid_reference", comment: ""))
        lineaCampione.lineColor = .systemRed
        lineaCampione.lineWidth = 1
        lineaCampione.lineDashLengths = [6, 3]
        lineaCampione.valueFont = AppFont.italicInfo
        lineaCampione.valueTextColor = AppColor.primaryText

        
        switch metric {
        case .passi, .distanza:
            lineaCampione.labelPosition = .rightBottom
        default:
            lineaCampione.labelPosition = .leftTop
        }

        chart.leftAxis.addLimitLine(lineaCampione)
    }

    private func createHorizontalBarChart(entries: [BarChartDataEntry], labels: [String], metric: HealthMetric) -> ChartViewBase {
        let chart = HorizontalBarChartView()
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors = [metric.color] // colore personalizzato per le colonne
        chart.data = BarChartData(dataSet: dataSet)
        chart.legend.enabled = false
        configureCommonChartProperties(chart: chart, labels: labels, metricName: metric.rawValue)
        return chart
    }
    
    private func createLineChart(entries: [BarChartDataEntry], labels: [String], metric: HealthMetric) -> ChartViewBase {
        let lineChart = LineChartView()

        let lineDataSet = LineChartDataSet(entries: entries)
        lineDataSet.colors = [metric.color] // Colore linea
        lineDataSet.circleColors =  [metric.color] // Colore dei cerchi
        lineDataSet.valueColors = [metric.color]
        lineDataSet.valueTextColor = AppColor.primaryText
        lineDataSet.mode = .linear
        lineDataSet.drawFilledEnabled = true
        lineDataSet.fillAlpha = 0.5
        lineDataSet.fillColor = metric.color
        lineDataSet.drawCirclesEnabled = true
        lineDataSet.circleRadius = 6.0

        lineChart.data = LineChartData(dataSet: lineDataSet)
        lineChart.legend.enabled = false
        configureCommonChartProperties(chart: lineChart, labels: labels, metricName: metric.rawValue)
        return lineChart
    }

    private func createDefaultBarChart(entries: [BarChartDataEntry], labels: [String], metric: HealthMetric) -> ChartViewBase {
        let barChart = BarChartView()
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors =  [metric.color] // colore personalizzato per le colonne
        barChart.data = BarChartData(dataSet: dataSet)
        barChart.rightAxis.enabled = false
        barChart.legend.enabled = false
        configureCommonChartProperties(chart: barChart, labels: labels, metricName: metric.rawValue)
        return barChart
    }

    private func wrapChartWithTitle(_ chart: ChartViewBase, title: String, unitMetric: String) -> UIView {

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AppFont.title
        titleLabel.textColor = AppColor.primaryText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let infoLabel = UILabel()
        infoLabel.text = NSLocalizedString("last_7gg_data", comment: "")
        infoLabel.font = AppFont.info
        infoLabel.textColor = AppColor.primaryText
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .left
        
        let unitLabel = UILabel()
        unitLabel.font = AppFont.info
        let fullText = String(format: NSLocalizedString("data_with_unit", comment: ""), unitMetric)
        let attributedText = NSMutableAttributedString(string: fullText)

        if let range = fullText.range(of: unitMetric) {
            let nsRange = NSRange(range, in: fullText)
            attributedText.addAttribute(.font, value: AppFont.italicDescription, range: nsRange)
        }

        unitLabel.attributedText = attributedText
        unitLabel.textColor = AppColor.primaryText
        unitLabel.numberOfLines = 0
        unitLabel.textAlignment = .left

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
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        
        let imageNoResult = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageNoResult.tintColor = AppColor.primaryIcon
        imageNoResult.translatesAutoresizingMaskIntoConstraints = false
        imageNoResult.contentMode = .scaleAspectFit
        
       
        let container = UIView()
        container.addSubview(imageNoResult)
        container.addSubview(label)

        container.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 100),
            imageNoResult.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageNoResult.topAnchor.constraint(equalTo: container.topAnchor, constant: 32),
            imageNoResult.heightAnchor.constraint(equalToConstant: 40),
            imageNoResult.widthAnchor.constraint(equalToConstant: 40),
            
            label.topAnchor.constraint(equalTo: imageNoResult.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16)
        ])

        return container
    }
    
    private func configureCommonChartProperties(chart: BarLineChartViewBase, labels: [String], metricName:String) {
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.heightAnchor.constraint(equalToConstant: 300).isActive = true

        chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        chart.xAxis.granularity = 1
        chart.xAxis.labelPosition = .bottom
        chart.setExtraOffsets(left: 0, top: 16, right: 16, bottom: 0)
        
        if metricName == HealthMetric.sonno.rawValue {
            chart.leftAxis.axisMinimum = 0
            chart.leftAxis.axisMaximum = 11
            chart.leftAxis.granularity = 1
            chart.leftAxis.granularityEnabled = true
        } else if metricName == HealthMetric.mindful.rawValue {
            chart.leftAxis.axisMinimum = 0
            chart.leftAxis.axisMaximum = 3
            chart.leftAxis.granularity = 1
            chart.leftAxis.granularityEnabled = true
        }
        
        chart.rightAxis.enabled = false
        chart.leftAxis.drawAxisLineEnabled = false
        chart.leftAxis.drawGridLinesEnabled = false
        chart.xAxis.drawGridLinesEnabled = false
        
        chart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeOutQuart)
    }
}
