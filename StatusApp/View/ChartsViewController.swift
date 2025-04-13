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
        "Passi": 7000, //numero di passi
        "Frequenza Cardiaca": 80, //bpm
        "HRV": 60, //millis
        "Distanza": 6000, //metri
        "Energia Attiva": 600 //kcal
    ]
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColor.backgroundColor
        title = "Grafici"
        
        setupStackView()
    }

    private func setupStackView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        stackView.axis = .vertical
        stackView.spacing = 24
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
            let chartView = createChartView(for: metricData.metric.rawValue, with: metricData.values.map { (value: $0.value, dateString: $0.date) })
            DispatchQueue.main.async {
                self.stackView.addArrangedSubview(chartView)
            }
        }
    }

    private func createChartView(for metricName: String, with values: [(value: String, dateString: String)]) -> UIView {
        var entries: [BarChartDataEntry] = []
        var labels: [String] = []

        for (index, dataPoint) in values.enumerated() {
            if let value = Double(dataPoint.value.components(separatedBy: CharacterSet.whitespaces).first ?? "") {
                entries.append(BarChartDataEntry(x: Double(index), y: value))
                labels.append(dataPoint.dateString)
            }
        }
        
        if entries.isEmpty {
            return makeEmptyChartView(for: metricName)
        }

        let chartView: ChartViewBase

        switch metricName {
        case HealthMetric.passi.rawValue, HealthMetric.distanza.rawValue:
            chartView = createHorizontalBarChart(entries: entries, labels: labels)
        case HealthMetric.frequenzaCardiaca.rawValue, HealthMetric.hrv.rawValue:
            chartView = createLineChart(entries: entries, labels: labels)
        default:
            chartView = createDefaultBarChart(entries: entries, labels: labels)
        }

        configureReferenceLine(for: chartView, metricName: metricName)
        setupLegened(chart: chartView, metricName: metricName)

        return wrapChartWithTitle(chartView, title: metricName)
    }
    
    private func configureReferenceLine(for chartView: ChartViewBase, metricName: String) {
        guard let riferimento = referenceValues[metricName],
              let chart = chartView as? BarLineChartViewBase else { return }

        let lineaCampione = ChartLimitLine(limit: riferimento, label: "Valore di riferimento")
        lineaCampione.lineColor = .systemRed
        lineaCampione.lineWidth = 1
        lineaCampione.lineDashLengths = [4, 2]
        lineaCampione.valueFont = AppFont.info
        lineaCampione.valueTextColor = .white

        
        switch metricName {
        case "Passi", "Distanza":
            lineaCampione.labelPosition = .rightBottom
        case "Frequenza Cardiaca", "HRV":
            lineaCampione.labelPosition = .leftTop
        default:
            lineaCampione.labelPosition = .rightTop
        }

        chart.leftAxis.addLimitLine(lineaCampione)

        chart.rightAxis.enabled = false
        chart.leftAxis.drawAxisLineEnabled = false
        chart.leftAxis.drawGridLinesEnabled = false
        chart.xAxis.drawGridLinesEnabled = false
    }

    private func createHorizontalBarChart(entries: [BarChartDataEntry], labels: [String]) -> ChartViewBase {
        let chart = HorizontalBarChartView()
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors = [ AppColor.primaryIcon] // colore personalizzato per le colonne
        chart.data = BarChartData(dataSet: dataSet)
        configureCommonChartProperties(chart: chart, labels: labels)
        return chart
    }
    
    private func createLineChart(entries: [BarChartDataEntry], labels: [String]) -> ChartViewBase {
        let lineChart = LineChartView()

        let lineDataSet = LineChartDataSet(entries: entries)
        lineDataSet.colors = [ AppColor.primaryIcon]// Colore linea
        lineDataSet.circleColors =  [ AppColor.primaryIcon] // Colore dei cerchi
        lineDataSet.valueColors = [ AppColor.primaryIcon]
        lineDataSet.valueTextColor = AppColor.primaryText
        lineDataSet.mode = .linear
        lineDataSet.drawFilledEnabled = true
        lineDataSet.fillAlpha = 0.5
        lineDataSet.fillColor = AppColor.primaryText
        lineDataSet.drawCirclesEnabled = true
        lineDataSet.circleRadius = 6.0

        lineChart.data = LineChartData(dataSet: lineDataSet)
        configureCommonChartProperties(chart: lineChart, labels: labels)
        return lineChart
    }

    private func createDefaultBarChart(entries: [BarChartDataEntry], labels: [String]) -> ChartViewBase {
        let barChart = BarChartView()
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors =  [ AppColor.primaryIcon] // colore personalizzato per le colonne
        barChart.data = BarChartData(dataSet: dataSet)
        configureCommonChartProperties(chart: barChart, labels: labels)
        return barChart
    }

    private func wrapChartWithTitle(_ chart: ChartViewBase, title: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AppFont.primary
        titleLabel.textColor = AppColor.primaryText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let container = UIStackView(arrangedSubviews: [titleLabel, chart])
        container.axis = .vertical
        container.spacing = 8
        return container
    }

    private func makeEmptyChartView(for metric: String) -> UIView {
        let label = UILabel()
        label.text = "Nessun dato disponibile per \"\(metric)\""
        label.font = AppFont.primary
        label.textColor = AppColor.primaryText
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.heightAnchor.constraint(equalToConstant: 100).isActive = true
        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16)
        ])

        return container
    }
    
    private func setupLegened(chart: ChartViewBase, metricName: String) {
        let unit: String
        switch metricName {
        case "Passi":
            unit = "Dati riportati in numero"
        case "Frequenza Cardiaca":
            unit = "Dati riportati in BPM"
        case "HRV":
            unit = "Dati riportati in ms"
        case "Sonno":
            unit = "Dati riportati in ore"
        case "Distanza":
            unit = "Dati riportati in m"
        case "Energia Attiva":
            unit = "Dati riportati in kcal"
        default:
            unit = "Dati riportati in min"
        }

        let legendEntries: [LegendEntry] = [
            LegendEntry(label: "Dati raccolti negli ultimi 7 giorni"),
            LegendEntry(label: unit)
        ]
        
        chart.legend.setCustom(entries: legendEntries)
        chart.legend.enabled = true
        chart.legend.horizontalAlignment = .left
        chart.legend.verticalAlignment = .bottom
        chart.legend.orientation = .horizontal
        chart.legend.drawInside = false
        chart.legend.font = AppFont.info
        chart.legend.textColor = AppColor.primaryText
    }
    
    private func configureCommonChartProperties(chart: BarLineChartViewBase, labels: [String]) {
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.heightAnchor.constraint(equalToConstant: 300).isActive = true
        chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        chart.xAxis.granularity = 1
        chart.xAxis.labelPosition = .bottom
        chart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeOutQuart)
    }
}
