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
    let store: OCKStore = .init(name: "CareKitStore", type: .inMemory)

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
    }

    func addDailySurveyTask() {
        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
        let schedule = OCKSchedule.dailyAtTime(hour: 8, minutes: 0, start: startDate, end: nil, text: nil)
        let task = OCKTask(id: "dailySurvey", title: "Sondaggio Giornaliero", carePlanID: nil, schedule: schedule)
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
        let today = Calendar.current.startOfDay(for: Date())
        let calendar = Calendar.current
        var statuses: [SurveyDayStatus] = []
        let group = DispatchGroup()

        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let query = OCKEventQuery(for: date)
            group.enter()

            store.fetchEvents(taskID: "dailySurvey", query: query, callbackQueue: .main) { result in
                defer { group.leave() }
                switch result {
                case .success(let events):
                    if let event = events.first {
                        let completed = event.outcome != nil
                        let mood = event.outcome?.values.first(where: { $0.kind == "mood" })?.integerValue
                        let energy = event.outcome?.values.first(where: { $0.kind == "energy" })?.integerValue

                        let status = SurveyDayStatus(date: date, completed: completed, mood: mood, energy: energy)
                        statuses.append(status)
                    }
                case .failure(let error):
                    print("Errore fetch eventi: \(error)")
                }
            }
        }

        group.notify(queue: .main) {
            let sorted = statuses.sorted { $0.date > $1.date }
            if let surveysView = self.view.subviews.compactMap({ $0 as? SurveysView }).first {
                if animated {
                    UIView.transition(with: surveysView.collectionView,
                                      duration: 0.3,
                                      options: .transitionCrossDissolve,
                                      animations: {
                                          surveysView.update(with: sorted)
                                      },
                                      completion: nil)
                } else {
                    surveysView.update(with: sorted)
                }
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
        store.fetchEvents(taskID: "dailySurvey", query: query, callbackQueue: .main) { result in
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
        let introStep = ORKInstructionStep(identifier: "introStep")
        introStep.title = "Benvenuto al sondaggio"
        introStep.text = "Ti verranno poste 2 domande.\nRispondere richiederà meno di un minuto."

        let moodQuestionStep = ORKQuestionStep(
            identifier: "moodQuestion",
            title: nil,
            question: "Come ti senti oggi?",
            answer: ORKAnswerFormat.scale(
                withMaximumValue: 10,
                minimumValue: 1,
                defaultValue: 0,
                step: 1,
                vertical: false,
                maximumValueDescription: "Molto bene",
                minimumValueDescription: "Molto male"
            )
        )
        
        moodQuestionStep.isOptional = false

        let energyQuestionStep = ORKQuestionStep(
            identifier: "energyQuestion",
            title: nil,
            question: "Quanta energia senti di avere oggi?",
            answer: ORKAnswerFormat.scale(
                withMaximumValue: 10,
                minimumValue: 1,
                defaultValue: 0,
                step: 1,
                vertical: false,
                maximumValueDescription: "Molto alta",
                minimumValueDescription: "Molto bassa"
            )
        )
        energyQuestionStep.isOptional = false

        let summaryStep = ORKCompletionStep(identifier: "summary")
        summaryStep.title = "Grazie!"
        summaryStep.text = "Hai completato il sondaggio."

        let task = ORKOrderedTask(identifier: "surveyTask", steps: [introStep, moodQuestionStep, energyQuestionStep, summaryStep])
        let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }

    // MARK: - ORKTaskViewControllerDelegate
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true)

        if reason == .completed {
            let today = Calendar.current.startOfDay(for: Date())
            let end = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            let query = OCKEventQuery(dateInterval: DateInterval(start: today, end: end))
            store.fetchEvents(taskID: "dailySurvey", query: query, callbackQueue: .main) { result in
                switch result {
                case .success(let events):
                    if let event = events.first {
                        var outcomeValues: [OCKOutcomeValue] = []

                        if let moodResult = (taskViewController.result.stepResult(forStepIdentifier: "moodQuestion")?.results?.first as? ORKScaleQuestionResult)?.scaleAnswer {
                            var moodValue = OCKOutcomeValue(moodResult.intValue)
                            moodValue.kind = "mood"
                            outcomeValues.append(moodValue)
                        }

                        if let energyResult = (taskViewController.result.stepResult(forStepIdentifier: "energyQuestion")?.results?.first as? ORKScaleQuestionResult)?.scaleAnswer {
                            var energyValue = OCKOutcomeValue(energyResult.intValue)
                            energyValue.kind = "energy"
                            outcomeValues.append(energyValue)
                        }

                        let outcome = OCKOutcome(taskID: event.task.localDatabaseID!,
                                                 taskOccurrenceIndex: event.scheduleEvent.occurrence,
                                                 values: outcomeValues)
                        self.store.addOutcome(outcome, callbackQueue: .main) { _ in
                            self.loadSurveyStatuses(animated: true)
                        }
                    }
                case .failure(let error):
                    print("Errore outcome: \(error)")
                }
            }
        }
    }
}
