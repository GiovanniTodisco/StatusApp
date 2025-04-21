//
//  SurveysViewController.swift
//  StatusApp
//
//  Created by Area mobile on 06/04/25.
//

import UIKit
import ResearchKit
import CareKit
import CareKitStore
import UserNotifications

class SurveysViewController: UIViewController, ORKTaskViewControllerDelegate {
    
    private let surveysView = SurveysView()
    let store = CareKitManager.shared.store
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(surveysView)
        surveysView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            surveysView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.APP_MARGIN),
            surveysView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            surveysView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            surveysView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        view.backgroundColor = AppColor.backgroundColor
        title = NSLocalizedString("survey", comment: "")
        addDailySurveyTask()
        
        surveysView.onSeeAllTapped = { [weak self] in
            let historyVC = SurveyHistoryViewController()
            self?.navigationController?.pushViewController(historyVC, animated: true)
        }
    }
    
    func addDailySurveyTask() {
        let startDate = Calendar.current.date(byAdding: .day, value: -CareKitManager.shared.historyDaysBack, to: Date())!
        let schedule = OCKSchedule.dailyAtTime(hour: 8, minutes: 0, start: startDate, end: nil, text: nil)
        let task = OCKTask(id: SurveyConstants.surveyTaskID, title: NSLocalizedString("daily_survey", comment: ""), carePlanID: nil, schedule: schedule)
        store.addTask(task, callbackQueue: .main) { result in
            switch result {
            case .failure(let error):
                print("Errore aggiunta task: \(error)")
            case .success:
                print("Task giornaliera aggiunta correttamente")
            }
        }
    }
    
    func loadSurveyStatuses(animated: Bool = false) {
        CareKitManager.shared.loadSurveyStatuses(daysBack: 7) { [weak self] statuses in
            guard let self = self else { return }
            if animated {
                UIView.transition(with: self.surveysView.collectionView,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.surveysView.update(with: statuses)
                },
                                  completion: nil)
            } else {
                self.surveysView.update(with: statuses)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkCareKitSurvey()
        loadSurveyStatuses()
    }
    
    func checkCareKitSurvey() {
        let today = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let query = OCKEventQuery(dateInterval: DateInterval(start: today, end: end))
        store.fetchEvents(taskID: SurveyConstants.surveyTaskID, query: query, callbackQueue: .main) { result in
            switch result {
            case .success(let events):
                if let event = events.first, event.outcome == nil {
                    let now = Date()
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.hour, .minute], from: now)
                    if let hour = components.hour, hour >= 8 {
                        self.startSurvey()
                    }
                }
            case .failure(let error):
                print("Errore fetch eventi: \(error)")
            }
        }
    }
    
    func startSurvey() {
        let introStep = ORKInstructionStep(identifier: SurveyConstants.introStep)
        introStep.title = NSLocalizedString("survey_welcome", comment: "")
        introStep.text = NSLocalizedString("survey_title", comment: "")
        
        let moodQuestionStep = ORKQuestionStep(
            identifier: SurveyConstants.moodQuestionID,
            title: nil,
            question: NSLocalizedString("how_do_you_feel", comment: ""),
            answer: ORKAnswerFormat.scale(
                withMaximumValue: 10,
                minimumValue: 1,
                defaultValue: 0,
                step: 1,
                vertical: false,
                maximumValueDescription: NSLocalizedString("very_well", comment: ""),
                minimumValueDescription: NSLocalizedString("very_bad", comment: "")
            )
        )
        
        moodQuestionStep.isOptional = false
        
        let energyQuestionStep = ORKQuestionStep(
            identifier: SurveyConstants.energyQuestionID,
            title: nil,
            question: NSLocalizedString("how_much_energy", comment: ""),
            answer: ORKAnswerFormat.scale(
                withMaximumValue: 10,
                minimumValue: 1,
                defaultValue: 0,
                step: 1,
                vertical: false,
                maximumValueDescription: NSLocalizedString("very_high", comment: ""),
                minimumValueDescription: NSLocalizedString("very_low", comment: "")
            )
        )
        energyQuestionStep.isOptional = false
        
        let summaryStep = ORKCompletionStep(identifier: SurveyConstants.completationID)
        summaryStep.title = NSLocalizedString("thanks", comment: "")
        summaryStep.text = NSLocalizedString("survey_done", comment: "")
        
        let task = ORKOrderedTask(identifier: SurveyConstants.taskID, steps: [introStep, moodQuestionStep, energyQuestionStep, summaryStep])
        let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }
    
    // MARK: - ORKTaskViewControllerDelegate
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true)
        
        if reason == .completed {
            CareKitManager.shared.saveSurveyOutcome(from: taskViewController.result) { [weak self] success in
                if success {
                    self?.loadSurveyStatuses(animated: true)
                }
            }
        }
    }
}
