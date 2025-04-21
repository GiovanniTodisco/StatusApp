//
//  MetricInfoViewController.swift
//  StatusApp
//
//  Created by Area mobile on 16/04/25.
//

import UIKit

/// Controller per la schermata Info di una metrica.
/// Semplifica la view usando `MetricInfoView`.
class MetricInfoViewController: UIViewController {
    private let metric: HealthMetric
    private var detailView: MetricInfoView!

    init(metric: HealthMetric) {
        self.metric = metric
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        detailView = MetricInfoView(metric: metric)
        view = detailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let sheet = sheetPresentationController {
            sheet.detents = [.large()]
        }
    }
}
