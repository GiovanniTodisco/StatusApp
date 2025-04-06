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
        
        // Step 2: Eligibilità da skippare
        
        // Step 3: Consenso
        let consentOverviewDocument = ORKConsentDocument()
        consentOverviewDocument.title = NSLocalizedString("consent", comment: "")
           
        let sectionTypes: [ORKConsentSectionType] = [.overview, .dataGathering, .privacy, .timeCommitment]

        let sections = OnboardingConstants.consentSectionKeys.enumerated().map { index, keys in
            let section = ORKConsentSection(type: sectionTypes[index])
            section.title = NSLocalizedString(keys.titleKey, comment: "")
            section.content = NSLocalizedString(keys.contentKey, comment: "")
            return section
        }

        consentOverviewDocument.sections = sections
        let consentInfoStep = ORKInstructionStep(identifier: OnboardingConstants.consentInfoStep)
        consentInfoStep.title = ""
        consentInfoStep.text = ""
        steps.append(consentInfoStep)
        
        let personalDataStep = ORKFormStep(identifier: OnboardingConstants.personalDataStep,
                                           title: NSLocalizedString("form_title", comment: ""),
                                           text: NSLocalizedString("form_description", comment: ""))

        var formItems: [ORKFormItem] = []
        personalDataStep.cardViewStyle = .bordered
        
        let formTitle: ORKFormItem = ORKFormItem(sectionTitle: NSLocalizedString("profile", comment: ""))
        formItems.append(formTitle)
        
        let firstNameAnswer = ORKTextAnswerFormat(maximumLength: 30)
        firstNameAnswer.placeholder = NSLocalizedString("form_first_name", comment: "")
        formItems.append(ORKFormItem(identifier: "firstName",
                                     text: NSLocalizedString("form_first_name", comment: ""),
                                     answerFormat: firstNameAnswer,
                                     optional: false))

        let lastNameAnswer = ORKTextAnswerFormat(maximumLength: 30)
        lastNameAnswer.placeholder = NSLocalizedString("form_last_name", comment: "")
        formItems.append(ORKFormItem(identifier: "lastName",
                                     text: NSLocalizedString("form_last_name", comment: ""),
                                     answerFormat: lastNameAnswer,
                                     optional: false))

        
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"

        let minimumDate = formatter.date(from: "1900/01/01")
        let maximumDate = Date()

        let birthDateAnswerFormat = ORKAnswerFormat.dateAnswerFormat(
            withDefaultDate: nil,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            calendar: calendar
        )
        
        formItems.append(ORKFormItem(identifier: "birthDate",
                                     text: NSLocalizedString("form_birthdate", comment: ""),
                                     answerFormat: birthDateAnswerFormat,
                                     optional: false))

        personalDataStep.formItems = formItems
        steps.append(personalDataStep)
        
        let consentDocument = ORKConsentDocument()
        if let htmlURL = Bundle.main.url(forResource: "Consent", withExtension: "html"),
           let htmlString = try? String(contentsOf: htmlURL, encoding: .utf8) {

            consentDocument.htmlReviewContent = htmlString
        }
        consentDocument.title = NSLocalizedString("signature_step_title", comment: "")
        
        
        let signature = ORKConsentSignature(forPersonWithTitle: nil, dateFormatString: nil, identifier: "ConsentSignature")
        signature.requiresName = false
        
        consentDocument.addSignature(signature)
        
        let reviewStep = ORKConsentReviewStep(identifier: OnboardingConstants.consentReviewStep, signature: signature, in: consentDocument)
        
        reviewStep.requiresScrollToBottom = true;
        reviewStep.reasonForConsent =  NSLocalizedString("review_step_msg_2", comment: "")
        
        steps.append(reviewStep)
        
        let healthPermissionStep = ORKInstructionStep(identifier: OnboardingConstants.healthPermissionStep)
        healthPermissionStep.title = NSLocalizedString("healthkit_permission_title", comment: "")
        healthPermissionStep.text = NSLocalizedString("healthkit_permission_text", comment: "")
        steps.append(healthPermissionStep)
        
        return ORKOrderedTask(identifier: OnboardingConstants.taskID, steps: steps)
    }
}
