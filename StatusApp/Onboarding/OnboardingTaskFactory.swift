//
//  OnboardingTaskFactory.swift
//  StatusApp
//
//  Created by Area mobile on 04/04/25.
//


import ResearchKit
import UIKit

struct OnboardingTaskFactory {
    
    static func makeOnboardingTask() -> ORKOrderedTask {
        var steps = [ORKStep]()
        
        // Step 1: Introduzione
        let introStep = ORKInstructionStep(identifier: OnboardingConstants.introStep)
        steps.append(introStep)
        
        // Step 2: Eligibilità
        let eligibilityStep = ORKQuestionStep(
            identifier: OnboardingConstants.eligibilityStep,
            title: NSLocalizedString("eligibility_title", comment: ""),
            question: "Hai più di 18 anni?",
            answer: ORKAnswerFormat.booleanAnswerFormat()
        )
        eligibilityStep.isOptional = true
        //steps.append(eligibilityStep)
        
        // Step 3: Consenso
        let consentDocument = ORKConsentDocument()
        consentDocument.title = NSLocalizedString("consent", comment: "")
        
        let section = ORKConsentSection(type: .overview)
        section.summary = "Parteciperai a uno studio volontario."
        section.content = "I tuoi dati saranno usati a fini di ricerca e studio."
        consentDocument.sections = [section]
        
        let signature = ORKConsentSignature(forPersonWithTitle: nil, dateFormatString: nil, identifier: "ConsentSignature")
        consentDocument.addSignature(signature)
        
        let consentInfoStep = ORKInstructionStep(identifier: OnboardingConstants.consentInfoStep)
        consentInfoStep.title = "Informazioni sul consenso"
        consentInfoStep.text = "Puoi interrompere la partecipazione in qualsiasi momento."
        
        let reviewStep = ORKConsentReviewStep(identifier: OnboardingConstants.consentReviewStep, signature: signature, in: consentDocument)
        reviewStep.text = "Premi continua per fornire il consenso."
        reviewStep.reasonForConsent = "Acconsento a partecipare allo studio."
        
        steps.append(consentInfoStep)
        steps.append(reviewStep)
        
        // Step 4: HealthKit permission
        let healthStep = ORKInstructionStep(identifier: OnboardingConstants.healthPermissionStep)
        healthStep.title = "Permessi dati salute"
        healthStep.text = "L'app chiederà accesso a dati di HealthKit come battito cardiaco, sonno, passi."
        steps.append(healthStep)
        
        return ORKOrderedTask(identifier: OnboardingConstants.taskID, steps: steps)
    }
}
