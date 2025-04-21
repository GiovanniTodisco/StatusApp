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

    let store: OCKStore = .init(name: "CareKitStore", type: .inMemory)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.backgroundColor
        title = NSLocalizedString("survey", comment: "")
        addDailySurveyTask()
    }

    func addDailySurveyTask() {
        let schedule = OCKSchedule.dailyAtTime(hour: 11, minutes: 4, start: Date(), end: nil, text: nil)
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkCareKitSurvey()
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
                        self.store.addOutcome(outcome, callbackQueue: .main) { _ in }
                    }
                case .failure(let error):
                    print("Errore outcome: \(error)")
                }
            }
        }
    }
}
