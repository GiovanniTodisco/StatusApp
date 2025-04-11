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

        var dateComponents = DateComponents()
        dateComponents.year = -13
        let maximumDate = calendar.date(byAdding: dateComponents, to: Date())

        let birthDateAnswerFormat = ORKAnswerFormat.dateAnswerFormat(
            withDefaultDate: nil,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            calendar: calendar
        )
        
        let birthDateItem = ORKFormItem(identifier: "birthDate",
                                        text: NSLocalizedString("form_birthdate", comment: ""),
                                        answerFormat: birthDateAnswerFormat,
                                        optional: false)
        let birthDateLearnMoreStep = ORKLearnMoreInstructionStep(identifier: "learnMoreBirthDate")
        birthDateLearnMoreStep.title = NSLocalizedString("learn_more_birthdate_title", comment: "")
        birthDateLearnMoreStep.text = NSLocalizedString("learn_more_birthdate_text", comment: "")
        birthDateItem.learnMoreItem = ORKLearnMoreItem(text: NSLocalizedString("learn_more_birthdate", comment: ""), learnMoreInstructionStep: birthDateLearnMoreStep)
        formItems.append(birthDateItem)
        
        let weightAnswer = ORKNumericAnswerFormat(style: .decimal, unit: "kg", minimum: 0, maximum: 300)
        let weightItem = ORKFormItem(identifier: "weight",
                                     text: NSLocalizedString("form_weight", comment: ""),
                                     answerFormat: weightAnswer,
                                     optional: true)
        let weightLearnMoreStep = ORKLearnMoreInstructionStep(identifier: "learnMoreWeight")
        weightLearnMoreStep.title = NSLocalizedString("learn_more_weight_title", comment: "")
        weightLearnMoreStep.text = NSLocalizedString("learn_more_weight_text", comment: "")
        weightItem.learnMoreItem = ORKLearnMoreItem(text: NSLocalizedString("learn_more_weight", comment: ""), learnMoreInstructionStep: weightLearnMoreStep)
        formItems.append(weightItem)

        let heightAnswer = ORKNumericAnswerFormat(style: .decimal, unit: "cm", minimum: 0, maximum: 300)
        let heightItem = ORKFormItem(identifier: "height",
                                     text: NSLocalizedString("form_height", comment: ""),
                                     answerFormat: heightAnswer,
                                     optional: true)
        let heightLearnMoreStep = ORKLearnMoreInstructionStep(identifier: "learnMoreHeight")
        heightLearnMoreStep.title = NSLocalizedString("learn_more_height_title", comment: "")
        heightLearnMoreStep.text = NSLocalizedString("learn_more_height_text", comment: "")
        heightItem.learnMoreItem = ORKLearnMoreItem(text: NSLocalizedString("learn_more_height", comment: ""), learnMoreInstructionStep: heightLearnMoreStep)
        formItems.append(heightItem)

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
