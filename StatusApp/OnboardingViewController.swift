//
//  ViewController.swift
//  StatusApp
//
//  Created by Area mobile on 01/04/25.
//

import UIKit
import ResearchKit

class OnboardingViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentOnboarding()
    }
   
    func presentOnboarding() {
        let taskViewController = ORKTaskViewController(task: onboardingTask(), taskRun: nil)
        taskViewController.delegate = self
        taskViewController.modalPresentationStyle = .fullScreen
        present(taskViewController, animated: true)
    }

    func onboardingTask() -> ORKOrderedTask {
        var steps = [ORKStep]()

        // Step 1: Introduction
        let introStep = ORKInstructionStep(identifier: "IntroStep")
        introStep.title = "Benvenuto in StatusApp"
        introStep.text = "Questa app raccoglie dati per supportare il monitoraggio dello stress lavorativo in forma anonima."
        steps.append(introStep)

        // Step 2: Eligibility
        let eligibilityStep = ORKQuestionStep(
            identifier: "EligibilityStep", title: "Eligibilità", question: "Hai più di 18 anni?", answer: ORKAnswerFormat.booleanAnswerFormat()
        )
        eligibilityStep.isOptional = false // oppure true
        steps.append(eligibilityStep)

        // Step 3: Consent
        let consentDocument = ORKConsentDocument()
        consentDocument.title = "Consenso Informato"

        let section = ORKConsentSection(type: .overview)
        section.summary = "Parteciperai a uno studio volontario."
        section.content = "I tuoi dati saranno utilizzati solo per scopi informativi e resteranno sul tuo dispositivo."
        consentDocument.sections = [section]

        let signature = ORKConsentSignature(forPersonWithTitle: nil, dateFormatString: nil, identifier: "ConsentSignature")
        consentDocument.addSignature(signature)

        let consentInfoStep = ORKInstructionStep(identifier: "ConsentInfoStep")
        consentInfoStep.title = "Informazioni sul consenso"
        consentInfoStep.text = "Partecipi volontariamente a uno studio sul benessere psicofisico. I tuoi dati resteranno sul dispositivo e non saranno condivisi. La partecipazione è anonima e puoi interrompere in qualsiasi momento."
        
        let reviewStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, in: consentDocument)
        reviewStep.text = "Premi continua per fornire il consenso."
        reviewStep.reasonForConsent = "Acconsento a partecipare allo studio."

        steps.append(consentInfoStep)
        steps.append(reviewStep)

        // Step 4: Health Data Permission (informativa)
        let healthStep = ORKInstructionStep(identifier: "HealthPermissionStep")
        healthStep.title = "Permessi dati salute"
        healthStep.text = "Dopo il consenso, l'app ti chiederà accesso ai dati di HealthKit come sonno, frequenza cardiaca, ecc."
        steps.append(healthStep)

        return ORKOrderedTask(identifier: "OnboardingTask", steps: steps)
    }
}

extension OnboardingViewController: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true) {
            if reason == .completed {
                print("Onboarding completato!")
                // Qui puoi passare alla dashboard o salvare lo stato di completamento
            }
        }
    }
}
