//
//  OnboardingConstants.swift
//  StatusApp
//
//  Created by Area mobile on 04/04/25.
//


struct OnboardingConstants {
    static let introStep = "IntroStep"
    static let consentInfoStep = "ConsentInfoStep"
    static let consentReviewStep = "ConsentReviewStep"
    static let personalDataStep = "PersonalDataStep"
    static let healthPermissionStep = "HealthPermissionStep"
    static let taskID = "OnboardingTask"
    
    static let consentSectionKeys: [(titleKey: String, contentKey: String)] = [
        ("consent_overview_title", "consent_overview_content"),
        ("consent_data_title", "consent_data_content"),
        ("consent_privacy_title", "consent_privacy_content"),
        ("consent_time_title", "consent_time_content")
    ]
}
