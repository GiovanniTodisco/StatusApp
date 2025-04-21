//
//  SurveyHistoryViewController.swift
//  StatusApp
//
//  Created by Area mobile on 21/04/25.
//

import UIKit
import CareKit
import CareKitStore

class SurveyHistoryViewController: UIViewController {

    private let surveysView = SurveysHistoryView()
    private var statuses: [SurveyDayStatus] = []
    let store = CareKitManager.shared.store

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.backgroundColor
        title = NSLocalizedString("survey_history", comment: "")

        view.addSubview(surveysView)
        surveysView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            surveysView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            surveysView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            surveysView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            surveysView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        loadSurveyStatuses()
    }

    private func loadSurveyStatuses(daysBack: Int = 90) {
        CareKitManager.shared.loadSurveyStatuses(daysBack: daysBack) { [weak self] statuses in
            self?.statuses = statuses
            self?.surveysView.update(with: statuses)
        }
    }
}
