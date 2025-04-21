//
//  CareKitManager.swift
//  StatusApp
//
//  Created by Area mobile on 21/04/25.
//


import Foundation
import CareKitStore
import ResearchKit

final class CareKitManager {
    static let shared = CareKitManager()

    let store: OCKStore
    let historyDaysBack: Int = 90

    private init() {
        store = OCKStore(name: "CareKitStore", type: .onDisk)
    }
    
}

// MARK: - Caricamento sondaggi storici
/// Carica lo stato dei sondaggi degli ultimi N giorni dal CareKit store.
/// - Parameters:
///   - daysBack: Numero di giorni da retrodatare a partire da oggi.
///   - completion: Chiusura chiamata con l'elenco degli status ordinati per data decrescente.
extension CareKitManager {
    func loadSurveyStatuses(daysBack: Int, completion: @escaping ([SurveyDayStatus]) -> Void) {
        let today = Calendar.current.startOfDay(for: Date())
        let calendar = Calendar.current
        var statuses: [SurveyDayStatus] = []
        let group = DispatchGroup()

        for i in 0..<daysBack {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let query = OCKEventQuery(for: date)
            group.enter()

            store.fetchEvents(taskID: SurveyConstants.surveyTaskID, query: query, callbackQueue: .main) { result in
                defer { group.leave() }
                switch result {
                case .success(let events):
                    if let event = events.first {
                        let completed = event.outcome != nil
                        let mood = event.outcome?.values.first(where: { $0.kind == SurveyConstants.moodKey })?.integerValue
                        let energy = event.outcome?.values.first(where: { $0.kind == SurveyConstants.energyKey })?.integerValue
                        let status = SurveyDayStatus(date: date, completed: completed, mood: mood, energy: energy)
                        statuses.append(status)
                    }
                case .failure(let error):
                    print("Errore fetch eventi: \(error)")
                }
            }
        }

        group.notify(queue: .main) {
            completion(statuses.sorted { $0.date > $1.date })
        }
    }
}

// MARK: - Salvataggio outcome da ResearchKit
/// Salva nel CareKit store i valori raccolti dal sondaggio completato tramite ResearchKit.
/// - Parameters:
///   - result: Risultato ottenuto da ORKTaskViewController.
///   - completion: Chiusura chiamata con successo o fallimento.
extension CareKitManager {
    func saveSurveyOutcome(from result: ORKTaskResult, completion: @escaping (Bool) -> Void) {
        let today = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let query = OCKEventQuery(dateInterval: DateInterval(start: today, end: end))

        store.fetchEvents(taskID: SurveyConstants.surveyTaskID, query: query, callbackQueue: .main) { resultFetch in
            switch resultFetch {
            case .success(let events):
                guard let event = events.first else {
                    completion(false)
                    return
                }

                var outcomeValues: [OCKOutcomeValue] = []

                if let mood = (result.stepResult(forStepIdentifier: SurveyConstants.moodQuestionID)?.results?.first as? ORKScaleQuestionResult)?.scaleAnswer {
                    var moodValue = OCKOutcomeValue(mood.intValue)
                    moodValue.kind = SurveyConstants.moodKey
                    outcomeValues.append(moodValue)
                }

                if let energy = (result.stepResult(forStepIdentifier: SurveyConstants.energyQuestionID)?.results?.first as? ORKScaleQuestionResult)?.scaleAnswer {
                    var energyValue = OCKOutcomeValue(energy.intValue)
                    energyValue.kind = SurveyConstants.energyKey
                    outcomeValues.append(energyValue)
                }

                let outcome = OCKOutcome(taskID: event.task.localDatabaseID!,
                                         taskOccurrenceIndex: event.scheduleEvent.occurrence,
                                         values: outcomeValues)

                self.store.addOutcome(outcome, callbackQueue: .main) { outcomeResult in
                    switch outcomeResult {
                    case .success:
                        completion(true)
                    case .failure(let error):
                        print("Errore salvataggio outcome: \(error)")
                        completion(false)
                    }
                }

            case .failure(let error):
                print("Errore fetch eventi per outcome: \(error)")
                completion(false)
            }
        }
    }
}
